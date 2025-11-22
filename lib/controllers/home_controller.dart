import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var transactions = <TransactionModel>[].obs;
  var isLoading = true.obs;

  var totalBalance = 0.0.obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    String uid = _auth.currentUser!.uid;
    transactions.bindStream(_firestoreService.getTransactions(uid));
    ever(transactions, (_) => calculateTotals());
  }

  void calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = income - expense;
  }

  Future<void> addTransaction(TransactionModel t) async {
    try {
      await _firestoreService.addTransaction(t);
      Get.back();
      Get.snackbar(
        "Success",
        "Transaction added",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _firestoreService.deleteTransaction(id);
  }
}
