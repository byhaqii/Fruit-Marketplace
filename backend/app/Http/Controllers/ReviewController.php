<?php

namespace App\Http\Controllers;

use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ReviewController extends Controller
{
    /**
     * Menampilkan review untuk produk tertentu.
     */
    public function index($produk_id)
    {
        $reviews = Review::where('produk_id', $produk_id)
                        ->with('user') // Tampilkan data user yang memberi review
                        ->latest()
                        ->get();
        
        return response()->json($reviews);
    }

    /**
     * Menyimpan review baru untuk produk tertentu.
     */
    public function store(Request $request, $produk_id)
    {
        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'komentar' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Opsional: Cek apakah user sudah pernah membeli produk ini
        // ...

        $review = Review::create([
            'user_id' => Auth::id(),
            'produk_id' => $produk_id,
            'rating' => $request->rating,
            'komentar' => $request->komentar,
        ]);

        return response()->json([
            'message' => 'Review berhasil ditambahkan',
            'data' => $review
        ], 201);
    }
}