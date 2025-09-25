import 'package:cloud_functions/cloud_functions.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';

class MercadoPagoService {
  final CloudFunctions _cloudFunctions = CloudFunctions.instance;

  Future<void> startDonation(double amount, String description) async {
    try {
      final HttpsCallable callable = _cloudFunctions.getHttpsCallable(
        functionName: 'createPaymentPreference',
      );

      final result = await callable.call(<String, dynamic>{
        'amount': amount,
        'description': description,
        'type': 'donation',
      });

      final preferenceId = result.data['id'] as String;
      
      // Abrir checkout de Mercado Pago
      await MercadoPago().startCheckout(
        preferenceId: preferenceId,
        publicKey: 'TU_PUBLIC_KEY', // Debe venir de las variables de entorno
      );
    } catch (e) {
      throw Exception('Error al crear preferencia de pago: $e');
    }
  }

  Future<void> startSubscription(double amount, String description) async {
    try {
      final HttpsCallable callable = _cloudFunctions.getHttpsCallable(
        functionName: 'createPaymentPreference',
      );

      final result = await callable.call(<String, dynamic>{
        'amount': amount,
        'description': description,
        'type': 'subscription',
      });

      final preferenceId = result.data['id'] as String;
      
      await MercadoPago().startCheckout(
        preferenceId: preferenceId,
        publicKey: 'TU_PUBLIC_KEY',
      );
    } catch (e) {
      throw Exception('Error al crear suscripción: $e');
    }
  }
}