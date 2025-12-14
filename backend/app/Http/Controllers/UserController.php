<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class UserController extends Controller
{
    private function isAdmin(Request $request): bool
    {
        return $request->user() && $request->user()->role === 'admin';
    }

    public function index(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        return response()->json(User::all());
    }

    public function show(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        $user = User::find($id);
        return $user ? response()->json($user) : response()->json(['message' => 'Not found'], 404);
    }

    // --- FITUR CREATE ---
    public function store(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);

        try {
            $this->validate($request, [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6',
                'role' => 'required|in:admin,penjual,pembeli',
                'alamat' => 'nullable|string',          // Validasi tambahan
                'mobile_number' => 'nullable|string',   // Validasi tambahan
            ]);
        } catch (ValidationException $e) {
             return response()->json(['message' => 'Input tidak valid', 'errors' => $e->errors()], 422);
        }

        $user = User::create([
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'password' => Hash::make($request->input('password')),
            'role' => $request->input('role'),
            'alamat' => $request->input('alamat'),                  // Simpan Alamat
            'mobile_number' => $request->input('mobile_number'),    // Simpan No HP
        ]);

        return response()->json($user, 201);
    }

    // --- FITUR UPDATE ---
    public function update(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        
        $user = User::find($id);
        if (!$user) return response()->json(['message' => 'User tidak ditemukan'], 404);

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'email' => 'string|email|unique:users,email,' . $id, 
            'role' => 'in:admin,penjual,pembeli',
            'password' => 'nullable|string|min:6',
            'alamat' => 'nullable|string',
            'mobile_number' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Input tidak valid', 'errors' => $validator->errors()], 422);
        }

        // Update data text termasuk alamat dan mobile_number
        $user->fill($request->only(['name', 'email', 'role', 'alamat', 'mobile_number']));

        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        return response()->json(['message' => 'User berhasil diperbarui', 'data' => $user]);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        $user = User::find($id);
        if (!$user) return response()->json(['message' => 'Not found'], 404);
        if ($request->user()->id == $id) return response()->json(['message' => 'Tidak bisa hapus diri sendiri'], 403);

        $user->delete();
        return response()->json(['message' => 'Pengguna berhasil dihapus']);
    }

    // Get user statistics for dashboard
    public function getStats(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        
        $totalUsers = User::count();
        
        // New users: created in last 7 days
        $newUsers = User::where('created_at', '>=', Carbon::now()->subDays(7))->count();
        
        // Active users: users who have made transactions, created products, or have notifications in last 30 days
        // We'll count distinct users from transactions
        $activeUserIds = \DB::table('transaksi')
            ->where('created_at', '>=', Carbon::now()->subDays(30))
            ->distinct()
            ->pluck('user_id')
            ->toArray();
        
        // Also include sellers who created/updated products recently
        $activeSellerIds = \DB::table('produk')
            ->where('updated_at', '>=', Carbon::now()->subDays(30))
            ->distinct()
            ->pluck('user_id')
            ->toArray();
        
        // Merge and count unique users
        $allActiveIds = array_unique(array_merge($activeUserIds, $activeSellerIds));
        $activeUsers = count($allActiveIds);
        
        return response()->json([
            'total_users' => $totalUsers,
            'new_users' => $newUsers,
            'active_users' => $activeUsers,
        ]);
    }

    // Get user growth data for chart (penambahan user)
    public function getUserGrowth(Request $request): JsonResponse
    {
        if (!$this->isAdmin($request)) return response()->json(['message' => 'Akses ditolak'], 403);
        
        $period = $request->input('period', 'daily'); // 'daily', 'monthly', 'yearly'
        $data = [];
        $labels = [];
        $cumulativeCount = 0;

        if ($period === 'daily') {
            // Last 7 days - show daily new user additions
            for ($i = 6; $i >= 0; $i--) {
                $date = Carbon::now()->subDays($i);
                $newUsersCount = User::whereDate('created_at', $date->toDateString())->count();
                $cumulativeCount += $newUsersCount;
                $data[] = (float) $newUsersCount; // Daily additions
                $labels[] = $date->format('M d');
            }
        } elseif ($period === 'monthly') {
            // Last 12 months - show monthly new user additions
            for ($i = 11; $i >= 0; $i--) {
                $date = Carbon::now()->subMonths($i);
                $newUsersCount = User::whereYear('created_at', $date->year)
                    ->whereMonth('created_at', $date->month)
                    ->count();
                $cumulativeCount += $newUsersCount;
                $data[] = (float) $newUsersCount; // Monthly additions
                $labels[] = $date->format('M Y');
            }
        } elseif ($period === 'yearly') {
            // Last 5 years - show yearly new user additions
            for ($i = 4; $i >= 0; $i--) {
                $date = Carbon::now()->subYears($i);
                $newUsersCount = User::whereYear('created_at', $date->year)->count();
                $cumulativeCount += $newUsersCount;
                $data[] = (float) $newUsersCount; // Yearly additions
                $labels[] = $date->format('Y');
            }
        }

        return response()->json([
            'data' => $data,
            'labels' => $labels,
            'total_growth' => $cumulativeCount,
        ]);
    }
}