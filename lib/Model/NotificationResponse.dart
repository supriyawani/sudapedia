class NotificationResponse {
  String? success;
  String? failure;
  String? msg;
  List<NotificationArr>? notificationArr;

  NotificationResponse(
      this.success, this.failure, this.msg, this.notificationArr);

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    failure = json['Failure'];
    msg = json['msg'];

    if (json['notifications_arr'] != null) {
      notificationArr = <NotificationArr>[];
      json['notifications_arr'].forEach((v) {
        notificationArr!.add(NotificationArr.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    data['Failure'] = failure;
    data['msg'] = msg;
    if (notificationArr != null) {
      data['notifications_arr'] =
          notificationArr!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationArr {
  String? id;
  String? title;
  String? nottifications;
  String? type;
  String? createdDate;
  String? createdTime;

  NotificationArr.name(this.id, this.title, this.nottifications, this.type,
      this.createdDate, this.createdTime);

  NotificationArr.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    nottifications = json['notifications'];
    type = json['type'];
    createdDate = json['created_on_date'];
    createdTime = json['created_on_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['title'] = this.title;
    data['notifications'] = this.nottifications;
    data['type'] = this.type;
    data['created_on_date'] = this.createdDate;
    data['created_on_time'] = this.createdTime;
    return data;
  }
}
