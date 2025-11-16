<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Wallet extends Model
{
    protected $table = 'wallets';
    
    protected $fillable = [
        'clientId',
        'balance',
    ];

    protected $casts = [
        'balance' => 'decimal:2',
    ];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class, 'clientId');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'walletId');
    }

    public function paymentSessions(): HasMany
    {
        return $this->hasMany(PaymentSession::class, 'walletId');
    }
}

