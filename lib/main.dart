import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key) {
    _controller.view = DateRangePickerView.month;
    final todayDate = DateTime.now();
    _controller.displayDate = todayDate;
    _controller.selectedDate = todayDate;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      visibleDates.value = PickerDateRange(DateTime(todayDate.year, todayDate.month),
          DateTime(todayDate.year, todayDate.month + 1, 0));
    });
  }

  final _controller = DateRangePickerController();
  final _showTrailingAndLeadingDates = false;
  final _enableSwipingSelection = true;
  final _showWeekNumber = false;
  Rx<PickerDateRange> visibleDates = PickerDateRange(DateTime.now(), DateTime.now()).obs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: Get.width,
          color: Get.theme.backgroundColor,
          child: AspectRatio(
            aspectRatio: 347 / 280,
            child: SfDateRangePicker(
              controller: _controller,
              minDate: DateTime.now(),
              maxDate: DateTime.now().add(const Duration(days: 364)),
              selectionColor: Colors.transparent,
              monthViewSettings: DateRangePickerMonthViewSettings(
                enableSwipeSelection: _showTrailingAndLeadingDates,
                showTrailingAndLeadingDates: _enableSwipingSelection,
                showWeekNumber: _showWeekNumber,
              ),
              headerStyle: DateRangePickerHeaderStyle(
                textStyle: Get.textTheme.bodyText2!.copyWith(
                  color: Get.theme.colorScheme.primaryVariant,
                ),
                textAlign: TextAlign.center,
              ),
              onSelectionChanged: (details) {
                _controller.selectedDate = details.value;
              },
              onViewChanged: (details) {
                DateTime startDay;
                DateTime endDay;
                if ((details.visibleDateRange.startDate!.month.toDouble() -
                            details.visibleDateRange.endDate!.month.toDouble())
                        .abs() >
                    1) {
                  // Defer most days month when there's difference in months more than 1
                  final centerMonth = details.visibleDateRange.startDate!.add(Duration(days: 15));
                  startDay = DateTime(centerMonth.year, centerMonth.month, 1);
                  endDay = DateTime(centerMonth.year, centerMonth.month + 1, 0);
                } else {
                  final centerMonth = details.visibleDateRange.startDate!;
                  startDay = DateTime(
                    centerMonth.year,
                    centerMonth.month,
                    centerMonth.day,
                  );
                  endDay = DateTime(startDay.year, startDay.month + 1, 0);
                }

                print('START DAY $startDay END DAY $endDay');

                visibleDates.value = PickerDateRange(startDay, endDay);

                var endDate = visibleDates.value.startDate;
                // _controller.selectedDate = endDate;
              },
              cellBuilder: (context, details) {
                if (_controller.view == DateRangePickerView.month) {
                  final inputDate = details.date;
                  print('T inp ${inputDate} ${visibleDates.value.startDate}');
                  if (!visibleDates.value.startDate!.isSameMonth(inputDate)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Get.theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(3),
                          border: null),
                      alignment: Alignment.center,
                      child: Text(
                        details.date.day.toString(),
                        style: Get.textTheme.bodyText1!.copyWith(
                          color: Get.theme.colorScheme.primaryVariant,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  final isSelected = _controller.selectedDate!.isSameDay(inputDate);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: isSelected ? Get.theme.colorScheme.secondary : Color(0xFFB5FFD7),
                        borderRadius: BorderRadius.circular(3),
                        border: isSelected ? Border.all(color: Get.theme.primaryColor) : null),
                    alignment: Alignment.center,
                    child: Text(
                      details.date.day.toString(),
                      style: Get.textTheme.bodyText1!.copyWith(
                        color: Get.theme.colorScheme.primaryVariant,
                        fontSize: 14,
                      ),
                    ),
                  );
                } else if (_controller.view == DateRangePickerView.year) {
                  final now = details.date;
                  return Container(
                    width: details.bounds.width,
                    height: details.bounds.height,
                    alignment: Alignment.center,
                    child: Text(now.toString()),
                  );
                } else if (_controller.view == DateRangePickerView.decade) {
                  return Container(
                    width: details.bounds.width,
                    height: details.bounds.height,
                    alignment: Alignment.center,
                    child: Text(details.date.year.toString()),
                  );
                } else {
                  final int yearValue = (details.date.year ~/ 10) * 10;
                  return Container(
                    width: details.bounds.width,
                    height: details.bounds.height,
                    alignment: Alignment.center,
                    child: Text(yearValue.toString() + ' - ' + (yearValue + 9).toString()),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

extension DateTimeEx on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }
}
