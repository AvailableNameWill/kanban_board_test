/*
*
_onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
  setState(() {
    // Solo permitir rangos que comiencen hoy o en el futuro
    if (start != null && start.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
      _selectedDay = null;
      _focusedDay = focusDay;
      _rangeStart = start;
      _rangeEnd = end;
    } else {
      // Reiniciar si el rango seleccionado está en el pasado
      _rangeStart = null;
      _rangeEnd = null;
    }
  });
}

* /* Cargar los proyectos y hacer que en el DropDownButton aparezcan de 3 en 3, tiene que salir el nombre del proyecto
* Al seleccionar un proyecto se le tiene que asignar el color de ese proyecto a la tarea, si la tarea no tiene un
* proyecto asignado por defecto tendra el color blanco */

/*
*
Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<TasksBloc, TasksState>(
                        listener: (context, state) {
                          if (state is AddTaskFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(state.error, kRed));
                          }
                          if (state is AddTasksSuccess) {
                            Navigator.pop(context);
                          }
                        }, builder: (context, state) {
                      return ListView(
                        children: [
                          TableCalendar(
                            calendarFormat: _calendarFormat,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                              CalendarFormat.week: 'Week',
                            },
                            rangeSelectionMode: RangeSelectionMode.toggledOn,
                            focusedDay: _focusedDay,
                            firstDay: DateTime.utc(2023, 1, 1),
                            lastDay: DateTime.utc(2030, 1, 1),
                            onPageChanged: (focusDay) {
                              _focusedDay = focusDay;
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            rangeStartDay: _rangeStart,
                            rangeEndDay: _rangeEnd,
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onRangeSelected: _onRangeSelected,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(.1),
                                borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                            child: buildText(
                                _rangeStart != null && _rangeEnd != null
                                    ? 'Task starting at ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                                    : 'Select a date range',
                                kPrimaryColor,
                                textSmall,
                                FontWeight.w400,
                                TextAlign.start,
                                TextOverflow.clip),
                          ),
                          const SizedBox(height: 5),
                          buildText(
                              'Title',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 5,
                          ),
                          BuildTextField(
                              hint: "Task Title",
                              controller: title,
                              inputType: TextInputType.text,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(
                            height: 5,
                          ),
                          buildText(
                              'Select project',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text(selectedProject ?? "Seleccione un proyecto",
                                style: const TextStyle(fontSize: 16, color: kBlackColor),),
                              items: projectOptions.map((project) => DropdownMenuItem<String>(
                                  value: project,
                                  child: Text(
                                      project, style:
                                  const TextStyle(fontSize: 16),
                                  ),
                              )).toList(),
                              value: selectedProject,
                              onChanged: (value){
                                setState(() {
                                  selectedProject = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: kGrey1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                elevation: 8,
                                decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                iconEnabledColor: kBlackColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          buildText(
                              'Select User',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    selectedUser ?? 'Seleccione un usuario',
                                    style: const TextStyle( fontSize: 16, color: kBlackColor),
                                  ),
                                  items: userOptions.map((user) => DropdownMenuItem<String>(
                                      value: user,
                                      child: Text(
                                        user, style: const TextStyle(fontSize: 16),
                                      ),
                                  )).toList(),
                                value: selectedUser,
                                onChanged: (value){
                                    setState(() {
                                      selectedUser = value;
                                    });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kGrey1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  elevation: 8,
                                  decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  iconEnabledColor: kBlackColor
                                ),
                              ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          buildText(
                              'Description',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 5,
                          ),
                          BuildTextField(
                              hint: "Task Description",
                              controller: description,
                              inputType: TextInputType.multiline,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                      backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          kWhiteColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Cancel',
                                          kBlackColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                      backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          kPrimaryColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      final String taskId = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      var taskModel = TaskModel(
                                          id: taskId,
                                          title: title.text,
                                          description: description.text,
                                          start_date_time: _rangeStart,
                                          stop_date_time: _rangeEnd);
                                      context.read<TasksBloc>().add(
                                          AddNewTaskEvent(
                                              taskModel: taskModel));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Save',
                                          kWhiteColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      );
                    }))
*
* */

/*
*
BlocListener<TasksBloc, TasksState>(
                  listener: (context, state){
                    if (state is AddTaskFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          getSnackBar(state.error, kRed));
                    }
                    if(state is AddTasksSuccess){
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        TableCalendar(
                          calendarFormat: _calendarFormat,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                            CalendarFormat.week: 'Week',
                          },
                          rangeSelectionMode: RangeSelectionMode.toggledOn,
                          focusedDay: _focusedDay,
                          firstDay: DateTime.utc(2023, 1, 1),
                          lastDay: DateTime.utc(2030, 1, 1),
                          onPageChanged: (focusDay) {
                            _focusedDay = focusDay;
                          },
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          rangeStartDay: _rangeStart,
                          rangeEndDay: _rangeEnd,
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onRangeSelected: _onRangeSelected,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(.1),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                          child: buildText(
                              _rangeStart != null && _rangeEnd != null
                                  ? 'Task starting at ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                                  : 'Select a date range',
                              kPrimaryColor,
                              textSmall,
                              FontWeight.w400,
                              TextAlign.start,
                              TextOverflow.clip),
                        ),
                        const SizedBox(height: 5),
                        buildText(
                            'Title',
                            kBlackColor,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                            hint: "Task Title",
                            controller: title,
                            inputType: TextInputType.text,
                            fillColor: kWhiteColor,
                            onChange: (value) {}),
                        const SizedBox(
                          height: 5,
                        ),
                        buildText(
                            'Select project',
                            kBlackColor,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip),
                        const SizedBox(
                          height: 5,
                        ),
                        BlocBuilder<ProjectsBloc, ProjectsState>(
                          builder: (context, projectState){
                            if(projectState is FetchProjectSuccess){
                              final projects = projectState.projects;
                            }
                          },
                        )
                      ],
                    ),
                  ),
                )
*
* */
*
*
* */