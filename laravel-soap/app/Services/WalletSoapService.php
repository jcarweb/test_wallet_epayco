<?php

namespace App\Services;

use App\Models\Client;
use App\Models\Wallet;
use App\Models\PaymentSession;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Carbon\Carbon;

class WalletSoapService
{
    public function registerClient($params): array
    {
        try {
            // Log para depuración - convertir objeto a array para logging
            $paramsForLog = $params;
            if (is_object($params)) {
                $paramsForLog = json_decode(json_encode($params), true);
            }
            \Log::info('registerClient llamado', [
                'params_type' => gettype($params),
                'params' => $paramsForLog,
                'is_object' => is_object($params),
                'is_array' => is_array($params)
            ]);
            
            // Manejar diferentes formatos de parámetros SOAP
            // En document/literal, PHP SoapServer puede pasar los parámetros de diferentes formas
            $document = '';
            $fullName = '';
            $email = '';
            $phoneNumber = '';
            
            // Función helper para extraer valores
            $getValue = function($obj, $key, $default = '') {
                if (is_object($obj)) {
                    return isset($obj->$key) ? $obj->$key : (property_exists($obj, $key) ? $obj->$key : $default);
                } elseif (is_array($obj)) {
                    return $obj[$key] ?? $default;
                }
                return $default;
            };
            
            if (is_object($params)) {
                // Intentar extraer directamente
                $document = $getValue($params, 'document');
                $fullName = $getValue($params, 'fullName');
                $email = $getValue($params, 'email');
                $phoneNumber = $getValue($params, 'phoneNumber');
                
                // Si no se encontraron valores, puede que vengan dentro de un objeto con el nombre del elemento
                // (registerClientRequest en document/literal style)
                if (empty($document) && empty($fullName)) {
                    // Buscar dentro de propiedades del objeto que puedan contener los datos
                    $paramsArray = (array)$params;
                    
                    // Buscar en el array convertido
                    $document = $paramsArray['document'] ?? '';
                    $fullName = $paramsArray['fullName'] ?? '';
                    $email = $paramsArray['email'] ?? '';
                    $phoneNumber = $paramsArray['phoneNumber'] ?? '';
                    
                    // Si aún no hay datos, buscar en propiedades anidadas
                    if (empty($document) && empty($fullName)) {
                        foreach ($paramsArray as $key => $value) {
                            if (is_object($value) || is_array($value)) {
                                $document = $getValue($value, 'document') ?: $document;
                                $fullName = $getValue($value, 'fullName') ?: $fullName;
                                $email = $getValue($value, 'email') ?: $email;
                                $phoneNumber = $getValue($value, 'phoneNumber') ?: $phoneNumber;
                            }
                        }
                    }
                }
            } elseif (is_array($params)) {
                // Si viene como array
                $document = $params['document'] ?? '';
                $fullName = $params['fullName'] ?? '';
                $email = $params['email'] ?? '';
                $phoneNumber = $params['phoneNumber'] ?? '';
                
                // Si no hay datos directos, buscar en arrays anidados
                if (empty($document) && empty($fullName)) {
                    foreach ($params as $key => $value) {
                        if (is_array($value) || is_object($value)) {
                            $document = $getValue($value, 'document') ?: $document;
                            $fullName = $getValue($value, 'fullName') ?: $fullName;
                            $email = $getValue($value, 'email') ?: $email;
                            $phoneNumber = $getValue($value, 'phoneNumber') ?: $phoneNumber;
                        }
                    }
                }
            }
            
            \Log::info('Parámetros extraídos', [
                'document' => $document,
                'fullName' => $fullName,
                'email' => $email,
                'phoneNumber' => $phoneNumber
            ]);

            // Validación de campos requeridos
            if (empty($document) || empty($fullName) || empty($email) || empty($phoneNumber)) {
                return $this->buildResponse(false, '01', 'Todos los campos son requeridos', null);
            }

            // Validación de formato de email
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                return $this->buildResponse(false, '02', 'El formato del email no es válido', null);
            }

            // Validación de documento único
            $existingClient = Client::where('document', $document)->first();
            if ($existingClient) {
                return $this->buildResponse(false, '03', 'El documento ya está registrado', null);
            }

            // Validación de email único
            $existingEmail = Client::where('email', $email)->first();
            if ($existingEmail) {
                return $this->buildResponse(false, '04', 'El email ya está registrado', null);
            }

            DB::beginTransaction();

            // Crear cliente
            $client = Client::create([
                'document' => $this->sanitizeInput($document),
                'fullName' => $this->sanitizeInput($fullName),
                'email' => $this->sanitizeInput($email),
                'phoneNumber' => $this->sanitizeInput($phoneNumber),
            ]);

            // Crear billetera con saldo inicial
            $wallet = Wallet::create([
                'clientId' => $client->id,
                'balance' => 0.00,
            ]);

            DB::commit();

            return $this->buildResponse(true, '00', 'Cliente registrado exitosamente', [
                'clientId' => $client->id,
                'document' => $client->document,
                'fullName' => $client->fullName,
                'email' => $client->email,
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Error en registerClient: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->buildResponse(false, '99', 'Error interno del servidor: ' . $e->getMessage(), null);
        }
    }

    public function rechargeWallet($params): array
    {
        try {
            $document = $params->document ?? $params['document'] ?? '';
            $phoneNumber = $params->phoneNumber ?? $params['phoneNumber'] ?? '';
            $amount = floatval($params->amount ?? $params['amount'] ?? 0);

            // Validación de campos requeridos
            if (empty($document) || empty($phoneNumber) || $amount <= 0) {
                return $this->buildResponse(false, '01', 'Documento, celular y monto válido son requeridos', null);
            }

            // Buscar cliente
            $client = Client::where('document', $this->sanitizeInput($document))
                ->where('phoneNumber', $this->sanitizeInput($phoneNumber))
                ->first();

            if (!$client) {
                return $this->buildResponse(false, '05', 'Cliente no encontrado o datos no coinciden', null);
            }

            // Obtener o crear billetera
            $wallet = Wallet::firstOrCreate(
                ['clientId' => $client->id],
                ['balance' => 0.00]
            );

            DB::beginTransaction();

            $balanceBefore = $wallet->balance;
            $wallet->balance += $amount;
            $wallet->save();

            // Registrar transacción
            Transaction::create([
                'walletId' => $wallet->id,
                'type' => 'recharge',
                'amount' => $amount,
                'balanceBefore' => $balanceBefore,
                'balanceAfter' => $wallet->balance,
                'description' => 'Recarga de billetera',
            ]);

            DB::commit();

            return $this->buildResponse(true, '00', 'Recarga realizada exitosamente', [
                'document' => $client->document,
                'balanceBefore' => $balanceBefore,
                'amount' => $amount,
                'balanceAfter' => $wallet->balance,
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return $this->buildResponse(false, '99', 'Error interno del servidor: ' . $e->getMessage(), null);
        }
    }

    public function initiatePayment($params): array
    {
        try {
            $document = $params->document ?? $params['document'] ?? '';
            $phoneNumber = $params->phoneNumber ?? $params['phoneNumber'] ?? '';
            $amount = floatval($params->amount ?? $params['amount'] ?? 0);

            // Validación de campos requeridos
            if (empty($document) || empty($phoneNumber) || $amount <= 0) {
                return $this->buildResponse(false, '01', 'Documento, celular y monto válido son requeridos', null);
            }

            // Buscar cliente
            $client = Client::where('document', $this->sanitizeInput($document))
                ->where('phoneNumber', $this->sanitizeInput($phoneNumber))
                ->first();

            if (!$client) {
                return $this->buildResponse(false, '05', 'Cliente no encontrado o datos no coinciden', null);
            }

            // Obtener billetera
            $wallet = Wallet::where('clientId', $client->id)->first();

            if (!$wallet) {
                return $this->buildResponse(false, '06', 'Billetera no encontrada', null);
            }

            // Validar saldo suficiente
            if ($wallet->balance < $amount) {
                return $this->buildResponse(false, '07', 'Saldo insuficiente', [
                    'currentBalance' => $wallet->balance,
                    'requiredAmount' => $amount,
                ]);
            }

            DB::beginTransaction();

            // Generar token de 6 dígitos
            $token = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
            $sessionId = Str::uuid()->toString();

            // Crear sesión de pago
            $paymentSession = PaymentSession::create([
                'walletId' => $wallet->id,
                'sessionId' => $sessionId,
                'token' => $token,
                'amount' => $amount,
                'status' => 'pending',
                'expiresAt' => Carbon::now()->addMinutes(10),
            ]);

            DB::commit();

            // Enviar email con token
            try {
                Mail::raw("Su código de confirmación para el pago es: {$token}. Este código expira en 10 minutos.", function ($message) use ($client) {
                    $message->to($client->email)
                        ->subject('Código de confirmación de pago');
                });
            } catch (\Exception $e) {
                // Log error pero no fallar la operación
                \Log::error('Error enviando email: ' . $e->getMessage());
            }

            return $this->buildResponse(true, '00', 'Token enviado al correo electrónico', [
                'sessionId' => $sessionId,
                'message' => 'Se ha enviado un correo con el código de confirmación',
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return $this->buildResponse(false, '99', 'Error interno del servidor: ' . $e->getMessage(), null);
        }
    }

    public function confirmPayment($params): array
    {
        try {
            $sessionId = $params->sessionId ?? $params['sessionId'] ?? '';
            $token = $params->token ?? $params['token'] ?? '';

            // Validación de campos requeridos
            if (empty($sessionId) || empty($token)) {
                return $this->buildResponse(false, '01', 'ID de sesión y token son requeridos', null);
            }

            // Buscar sesión de pago
            $paymentSession = PaymentSession::where('sessionId', $this->sanitizeInput($sessionId))
                ->where('status', 'pending')
                ->first();

            if (!$paymentSession) {
                return $this->buildResponse(false, '08', 'Sesión de pago no encontrada o ya procesada', null);
            }

            // Validar expiración
            if (Carbon::now()->greaterThan($paymentSession->expiresAt)) {
                $paymentSession->status = 'expired';
                $paymentSession->save();
                return $this->buildResponse(false, '09', 'El token ha expirado', null);
            }

            // Validar token
            if ($paymentSession->token !== $token) {
                return $this->buildResponse(false, '10', 'Token inválido', null);
            }

            // Obtener billetera
            $wallet = $paymentSession->wallet;

            // Validar saldo nuevamente
            if ($wallet->balance < $paymentSession->amount) {
                return $this->buildResponse(false, '07', 'Saldo insuficiente', null);
            }

            DB::beginTransaction();

            // Descontar saldo
            $balanceBefore = $wallet->balance;
            $wallet->balance -= $paymentSession->amount;
            $wallet->save();

            // Actualizar sesión
            $paymentSession->status = 'confirmed';
            $paymentSession->confirmedAt = Carbon::now();
            $paymentSession->save();

            // Registrar transacción
            Transaction::create([
                'walletId' => $wallet->id,
                'type' => 'payment',
                'amount' => $paymentSession->amount,
                'balanceBefore' => $balanceBefore,
                'balanceAfter' => $wallet->balance,
                'sessionId' => $sessionId,
                'description' => 'Pago confirmado',
            ]);

            DB::commit();

            return $this->buildResponse(true, '00', 'Pago confirmado exitosamente', [
                'sessionId' => $sessionId,
                'amount' => $paymentSession->amount,
                'balanceBefore' => $balanceBefore,
                'balanceAfter' => $wallet->balance,
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return $this->buildResponse(false, '99', 'Error interno del servidor: ' . $e->getMessage(), null);
        }
    }

    public function checkBalance($params): array
    {
        try {
            $document = $params->document ?? $params['document'] ?? '';
            $phoneNumber = $params->phoneNumber ?? $params['phoneNumber'] ?? '';

            // Validación de campos requeridos
            if (empty($document) || empty($phoneNumber)) {
                return $this->buildResponse(false, '01', 'Documento y celular son requeridos', null);
            }

            // Buscar cliente
            $client = Client::where('document', $this->sanitizeInput($document))
                ->where('phoneNumber', $this->sanitizeInput($phoneNumber))
                ->first();

            if (!$client) {
                return $this->buildResponse(false, '05', 'Cliente no encontrado o datos no coinciden', null);
            }

            // Obtener billetera
            $wallet = Wallet::where('clientId', $client->id)->first();

            if (!$wallet) {
                return $this->buildResponse(true, '00', 'Consulta exitosa', [
                    'document' => $client->document,
                    'fullName' => $client->fullName,
                    'balance' => 0.00,
                ]);
            }

            return $this->buildResponse(true, '00', 'Consulta exitosa', [
                'document' => $client->document,
                'fullName' => $client->fullName,
                'balance' => $wallet->balance,
            ]);

        } catch (\Exception $e) {
            return $this->buildResponse(false, '99', 'Error interno del servidor: ' . $e->getMessage(), null);
        }
    }

    private function buildResponse(bool $success, string $codError, string $messageError, $data): array
    {
        return [
            'success' => $success,
            'cod_error' => $codError,
            'message_error' => $messageError,
            'data' => $data,
        ];
    }

    private function sanitizeInput(string $input): string
    {
        // Prevenir inyección SQL y XSS
        $input = trim($input);
        $input = stripslashes($input);
        $input = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
        return $input;
    }
}

