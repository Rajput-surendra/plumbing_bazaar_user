/// error : false
/// message : "Data retrieved successfully"
/// data : [{"order_id":"1","user_id":"581","estimate_id":"46","totalAmount":"500","mobile":"8770669965","username":"Rohit","seller_estimate":"uploads/user_image/IMG-20221104-WA0000.jpg"}]

class EstimateListModel {
  EstimateListModel({
      bool? error, 
      String? message, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _data = data;
}

  EstimateListModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  List<Data>? _data;
EstimateListModel copyWith({  bool? error,
  String? message,
  List<Data>? data,
}) => EstimateListModel(  error: error ?? _error,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get error => _error;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// order_id : "1"
/// user_id : "581"
/// estimate_id : "46"
/// totalAmount : "500"
/// mobile : "8770669965"
/// username : "Rohit"
/// seller_estimate : "uploads/user_image/IMG-20221104-WA0000.jpg"

class Data {
  Data({
      String? orderId, 
      String? userId, 
      String? estimateId, 
      String? totalAmount, 
      String? mobile, 
      String? username, 
      String? sellerEstimate,}){
    _orderId = orderId;
    _userId = userId;
    _estimateId = estimateId;
    _totalAmount = totalAmount;
    _mobile = mobile;
    _username = username;
    _sellerEstimate = sellerEstimate;
}

  Data.fromJson(dynamic json) {
    _orderId = json['order_id'];
    _userId = json['user_id'];
    _estimateId = json['estimate_id'];
    _totalAmount = json['totalAmount'];
    _mobile = json['mobile'];
    _username = json['username'];
    _sellerEstimate = json['seller_estimate'];
  }
  String? _orderId;
  String? _userId;
  String? _estimateId;
  String? _totalAmount;
  String? _mobile;
  String? _username;
  String? _sellerEstimate;
Data copyWith({  String? orderId,
  String? userId,
  String? estimateId,
  String? totalAmount,
  String? mobile,
  String? username,
  String? sellerEstimate,
}) => Data(  orderId: orderId ?? _orderId,
  userId: userId ?? _userId,
  estimateId: estimateId ?? _estimateId,
  totalAmount: totalAmount ?? _totalAmount,
  mobile: mobile ?? _mobile,
  username: username ?? _username,
  sellerEstimate: sellerEstimate ?? _sellerEstimate,
);
  String? get orderId => _orderId;
  String? get userId => _userId;
  String? get estimateId => _estimateId;
  String? get totalAmount => _totalAmount;
  String? get mobile => _mobile;
  String? get username => _username;
  String? get sellerEstimate => _sellerEstimate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['order_id'] = _orderId;
    map['user_id'] = _userId;
    map['estimate_id'] = _estimateId;
    map['totalAmount'] = _totalAmount;
    map['mobile'] = _mobile;
    map['username'] = _username;
    map['seller_estimate'] = _sellerEstimate;
    return map;
  }

}