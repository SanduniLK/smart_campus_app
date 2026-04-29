import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/timetable/timetable_bloc.dart';
import '../../../business_logic/timetable/timetable_event.dart';
import '../../../business_logic/timetable/timetable_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/timetable/day_selector.dart';
import '../../widgets/timetable/timetable_card.dart';
import '../../widgets/timetable/empty_timetable.dart';

class StudentTimetable extends StatefulWidget {
  const StudentTimetable({super.key});

  @override
  State<StudentTimetable> createState() => _StudentTimetableState();
}

class _StudentTimetableState extends State<StudentTimetable> {
  int _selectedDay = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    _selectedDay = _selectedDay == 7 ? 6 : _selectedDay;
    context.read<TimetableBloc>().add(LoadTimetableByDay(_selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Timetable', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          DaySelector(
            selectedDay: _selectedDay,
            onDaySelected: (day) {
              setState(() => _selectedDay = day);
              context.read<TimetableBloc>().add(LoadTimetableByDay(day));
            },
          ),
          Expanded(
            child: BlocBuilder<TimetableBloc, TimetableState>(
              builder: (context, state) {
                if (state is TimetableLoading) {
                  return const LoadingWidget();
                }
                if (state is TimetableError) {
                  return ErrorWidgetCustom(
                    message: state.message,
                    onRetry: () {
                      context.read<TimetableBloc>().add(LoadTimetableByDay(_selectedDay));
                    },
                  );
                }
                if (state is TimetableLoaded) {
                  if (state.slots.isEmpty) {
                    return const EmptyTimetable();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.slots.length,
                    itemBuilder: (context, index) {
                      final slot = state.slots[index];
                      return TimetableCard(
                        courseCode: slot.courseCode ?? '',
                        courseName: slot.courseName ?? '',
                        startTime: slot.startTime,
                        endTime: slot.endTime,
                        roomNumber: slot.roomNumber,
                        building: slot.building,
                        lecturerName: slot.lecturerName ?? '',
                        type: slot.type,
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}