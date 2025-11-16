<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    protected $table = 'transactions';
    
    protected $fillable = [
        'walletId',
        'type',
        'amount',
        'balanceBefore',
        'balanceAfter',
        'sessionId',
        'description',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'balanceBefore' => 'decimal:2',
        'balanceAfter' => 'decimal:2',
    ];

    protected $hidden = [
        'updated_at',
    ];

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class, 'walletId');
    }
}

