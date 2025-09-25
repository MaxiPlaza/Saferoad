const functions = require('firebase-functions');
const admin = require('firebase-admin');
const mercadopago = require('mercadopago');

admin.initializeApp();

mercadopago.configure({
  access_token: process.env.MERCADOPAGO_ACCESS_TOKEN || 'TEST-ACCESS-TOKEN'
});

// Validar solicitud de cruce seguro
exports.validateCrossRequest = functions.firestore
  .document('cross_requests/{requestId}')
  .onCreate(async (snapshot, context) => {
    const requestData = snapshot.data();
    const userId = requestData.userId;
    const semaforoId = requestData.semaforoId;
    
    // Verificar cooldown (última solicitud hace menos de 90 segundos)
    const cooldownTime = 90 * 1000; // 90 segundos
    const now = Date.now();
    
    const lastRequest = await admin.firestore()
      .collection('cross_requests')
      .where('userId', '==', userId)
      .where('semaforoId', '==', semaforoId)
      .orderBy('timestamp', 'desc')
      .limit(1)
      .get();
    
    if (!lastRequest.empty) {
      const lastRequestTime = lastRequest.docs[0].data().timestamp.toDate().getTime();
      if (now - lastRequestTime < cooldownTime) {
        await snapshot.ref.update({
          estado: 'rechazado',
          motivoRechazo: 'cooldown'
        });
        return null;
      }
    }
    
    // Verificar proximidad (simulación)
    // En producción, validar ubicación real del usuario
    
    // Aprobar solicitud
    await snapshot.ref.update({
      estado: 'aprobado'
    });
    
    // Simular cambio de semáforo
    await admin.firestore()
      .collection('traffic_lights')
      .doc(semaforoId)
      .update({
        estado: 'rojo',
        tiempoRestante: 20,
        ultimaActualizacion: admin.firestore.FieldValue.serverTimestamp()
      });
    
    return null;
  });

// Crear preferencia de pago para Mercado Pago
exports.createPaymentPreference = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }
  
  const { amount, description, type } = data;
  
  try {
    const preference = {
      items: [
        {
          title: description,
          unit_price: parseFloat(amount),
          quantity: 1,
        }
      ],
      back_urls: {
        success: 'https://saferoad.com/success',
        failure: 'https://saferoad.com/failure',
        pending: 'https://saferoad.com/pending'
      },
      auto_return: 'approved',
      notification_url: 'https://us-central1-saferoad.cloudfunctions.net/paymentWebhook'
    };
    
    const result = await mercadopago.preferences.create(preference);
    return { id: result.body.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error creating payment preference');
  }
});

// Webhook para confirmación de pagos
exports.paymentWebhook = functions.https.onRequest(async (req, res) => {
  const paymentId = req.query.id;
  
  try {
    const payment = await mercadopago.payment.get(paymentId);
    
    if (payment.body.status === 'approved') {
      // Actualizar estado del usuario o procesar suscripción
      await admin.firestore()
        .collection('payments')
        .doc(paymentId)
        .set({
          status: 'approved',
          amount: payment.body.transaction_amount,
          userId: payment.body.metadata.user_id,
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
    }
    
    res.status(200).send('OK');
  } catch (error) {
    console.error('Error processing payment:', error);
    res.status(500).send('Error');
  }
});