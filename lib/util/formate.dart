import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';

String formateTime(DateTime? time) {
  if (time == null) {
    return "";
  }
  return "${time.day}-${time.month}-${time.year}";
}

String formateDate(DateTime? time,{int level=0}) {
  if (time == null) {
    return "";
  }
  switch (level) {
    case -1:
      return "${time.hour}:${time.minute}";
    case 0:
      return "${time.day}-${time.month}";
    case 1:
      return "${time.day}-${time.month}-${time.year}";
    default:
      return "${time.day}-${time.month}-${time.year} ${time.hour}:${time.minute}";
  }
  return "${time.day}-${time.month}-${time.year}";
}

String enumeration(int num) {
  if (num == 1) {
    return "1er";
  }
  return "$num";
}

String formateRangeTime(DateTimeRange? range) {
  if (range == null) {
    return "";
  }
  final first = range.start;
  final last = range.end;
  final fmonth = first.month - 1;
  final lmonth = last.month - 1;

  if (first.year == last.year && first.month == last.month) {
    return "Du ${enumeration(first.day)}-${last.day} ${month[fmonth]} ${last.year}";
  } else if (first.year == last.year) {
    return "Du ${enumeration(first.day)} ${month[fmonth]} au ${enumeration(last.day)} ${month[lmonth]} ${first.year}";
  }
  return "Du ${enumeration(last.day)} ${month[fmonth]} ${first.year} au ${enumeration(last.day)} ${month[lmonth]} ${last.year}";
}

String formateRangeTimeShort(DateTimeRange? range) {
  if (range == null) {
    return "";
  }
  final first = range.start;
  final last = range.end;
  final fmonth = first.month - 1;
  final lmonth = last.month - 1;
  // final fin = 3;

  if (first.year == last.year && first.month == last.month) {
    return "${enumeration(first.day)}-${last.day} ${monthS[fmonth]} ${last.year}";
  } else if (first.year == last.year) {
    return "${enumeration(first.day)} ${monthS[fmonth]} au ${enumeration(last.day)} ${monthS[lmonth]} ${first.year}";
  }
  return "${enumeration(last.day)} ${monthS[fmonth]} ${first.year} au ${enumeration(last.day)} ${monthS[lmonth]} ${last.year}";
}

String helpAmountFormate(dynamic number, {bool sup = true, bool decim = true}) {
  //// deboger(tmp, "solde");
  final nb = number?.toString();
  if (nb == null || nb.toString().isEmpty) {
    return "";
  }
  String tmp = (double.parse(nb)).toStringAsFixed(2);
  if (!decim) {
    if (sup == true) {
      tmp = double.parse(tmp).round().toString();
    } else if (sup == false) {
      tmp = double.parse(tmp).floor().toString();
    }
  }

  String newChaine = "";
  final tmps = tmp.split('.');
  final tmp2 = tmps[0];
  int length = tmp2.length;
  final List<String> amountList = [];

  for (int i = (length - 1), j = 0; i >= 0; i--, j++) {
    if ((j) % 3 == 0) {
      amountList.add(' ');
    }
    amountList.add(tmp[i]);
  }

  for (final digit in amountList.reversed) {
    newChaine += digit;
  }

  newChaine = newChaine.trim();
  if (tmps.length == 2) {
    if (double.parse(tmps[1]) > 0) {
      newChaine += ".${tmps[1]}";
    }
  }
  return newChaine.trim();
}

DateTime? toDate(String? date){
if(date == null){
  return null;
}
try {
  return DateTime.parse(date);
} catch (e) {
  return null;
}

  
}