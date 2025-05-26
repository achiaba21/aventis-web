import 'package:flutter/material.dart';
import 'package:web_flutter/util/dialog/date_picker.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/widget/button/texte_button.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class DateItem extends StatefulWidget {
  const DateItem({super.key, this.selectedRange, this.onSelectRange});
  final Function(DateTimeRange?)? onSelectRange;
  final DateTimeRange? selectedRange;

  @override
  State<DateItem> createState() => _DateItemState();
}

class _DateItemState extends State<DateItem> {
  DateTimeRange? plage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    plage = widget.selectedRange ?? plage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TexteButton(
          reverse: true,
          image: Icons.calendar_month,
          text: "Date",
          onPressed: () async {
            if (widget.onSelectRange != null) {
              plage = await dateRangePicker(context);
              widget.onSelectRange!(plage);
              setState(() {});
            }
          },
        ),

        Expanded(
          child: TextSeed(formateRangeTime(plage), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
