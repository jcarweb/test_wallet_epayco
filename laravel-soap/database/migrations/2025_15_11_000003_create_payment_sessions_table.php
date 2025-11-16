<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
// Creación de la tabla de wallets para almacenar información de billeteras de clientes - ePayco
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payment_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('walletId')->constrained('wallets')->onDelete('cascade');
            $table->string('sessionId', 100)->unique();
            $table->string('token', 6);
            $table->decimal('amount', 15, 2);
            $table->enum('status', ['pending', 'confirmed', 'expired'])->default('pending');
            $table->timestamp('expiresAt');
            $table->timestamp('confirmedAt')->nullable();
            $table->timestamps();
            
            $table->index('sessionId');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payment_sessions');
    }
};

