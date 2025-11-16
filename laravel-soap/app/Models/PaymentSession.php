<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PaymentSession extends Model
{
    protected $table = 'payment_sessions';
    
    protected $fillable = [
        'walletId',
        'sessionId',
        'token',
        'amount',
        'status',
        'expiresAt',
        'confirmedAt',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'expiresAt' => 'datetime',
        'confirmedAt' => 'datetime',
    ];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class, 'walletId');
    }
}

