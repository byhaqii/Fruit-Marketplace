<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    // Ambil review berdasarkan ID Produk
    public function index($produkId)
    {
        $reviews = Review::where('produk_id', $produkId)
            ->with('user:id,name,avatar') // Ambil nama & avatar user saja
            ->latest()
            ->get();

        return response()->json($reviews);
    }

    // Simpan review baru
    public function store(Request $request, $produkId)
    {
        $this->validate($request, [
            'rating' => 'required|integer|min:1|max:5',
            'komentar' => 'nullable|string'
        ]);

        // Cek apakah user sudah pernah review produk ini?
        $existing = Review::where('produk_id', $produkId)
            ->where('user_id', Auth::id())
            ->first();

        if ($existing) {
            return response()->json(['message' => 'Anda sudah mereview produk ini'], 400);
        }

        $review = Review::create([
            'produk_id' => $produkId,
            'user_id' => Auth::id(), // Pastikan pakai user_id
            'rating' => $request->rating,
            'komentar' => $request->komentar
        ]);

        return response()->json($review, 201);
    }
}