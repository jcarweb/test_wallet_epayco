<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
// Creación de la tabla de wallets para almacenar información de billeteras de clientes - ePayco
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('walletId')->constrained('wallets')->onDelete('cascade');
            $table->enum('type', ['recharge', 'payment'])->default('recharge');
            $table->decimal('amount', 15, 2);
            $table->decimal('balanceBefore', 15, 2);
            $table->decimal('balanceAfter', 15, 2);
            $table->string('sessionId', 100)->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
            
            $table->index('walletId');
            $table->index('type');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};

