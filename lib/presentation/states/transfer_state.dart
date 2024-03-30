import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/transfer_repository.dart';
import 'package:mobile_app_slb/domain/usecases/outcome_usecase.dart';

import '../../data/models/cart_model.dart';
import '../../data/repository/assortment_repository.dart';
import '../../data/repository/newsale_repository.dart';
import '../../domain/usecases/currentstock_usecase.dart';
import '../../domain/usecases/productinfo_usecase.dart';

final transferProvider = ChangeNotifierProvider((ref) => TransferNotifier());

class TransferNotifier extends ChangeNotifier {
  List<CartModel> cartData = [];
  int? transactionId;

  Future<void> addToCart(CartModel newModel, int storeId) async {
    bool flag = false;
    for (var element in cartData) {
      if (element.model.id == newModel.model.id) {
        if (element.quantity + newModel.quantity <= element.model.quantity!) {
          element.quantity += newModel.quantity;
        } else {
          element.quantity = element.model.quantity!.toInt();
        }
        flag = true;
        break;
      }
    }
    if (!flag) {
      cartData.add(newModel);
    }
    notifyListeners();
  }

  Future<ProductInfoUseCase> getProductInfo(int productId) async {
    final data = await AssortmentRepository().getProductInfo(productId);
    return data;
  }

  Future<void> deleteFromCart(CartModel oldModel, int storeId) async {
    cartData.removeWhere((element) => element.model.id == oldModel.model.id);
    notifyListeners();
  }

  Future<void> updateCartModel(
      CartModel model, bool add, int? isText, int storeId) async {
    if (isText != null) {
      cartData
          .firstWhere((element) => element.model.id == model.model.id)
          .quantity = isText;
    } else {
      if (add) {
        cartData
            .firstWhere((element) => element.model.id == model.model.id)
            .quantity += 1;
      } else {
        cartData
            .firstWhere((element) => element.model.id == model.model.id)
            .quantity -= 1;
        if (model.quantity == 1) {
          deleteFromCart(model, storeId);
        }
      }
    }
    notifyListeners();
  }

  Future<OutcomeUseCase> createTransfer(int storeId) async {
    final data = await TransferRepository().createTransfer(cartData, storeId);
    return data;
  }

  Future<CurrentStockUseCase> getCurrentStock() async {
    final data = await NewSaleRepository().getCurrentStock();
    return data;
  }

  Future<void> deleteCart() async {
    transactionId = null;
    cartData = [];
    notifyListeners();
  }
}