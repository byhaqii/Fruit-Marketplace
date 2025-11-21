<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            // User yang menerima notifikasi
            $table->unsignedBigInteger('user_id'); 
            
            $table->string('title');
            $table->text('body');
            $table->string('type')->default('info'); // 'order', 'promo', 'system'
            $table->boolean('is_read')->default(false);
            
            // Opsional: Link ke data terkait (misal ID Transaksi)
            $table->unsignedBigInteger('related_id')->nullable(); 
            
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('notifications');
    }
};