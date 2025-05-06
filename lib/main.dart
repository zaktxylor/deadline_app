import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _themeColor = Colors.white; // project colour theme (white)
  String course = ''; // declare course variable (String)
  String year = ''; // declare year variable (string)
  bool _showExtraDropdown1 = false; // declare show extra option1 variable
  bool _showExtraDropdown2 = false; // declare show extra option2 variable
  bool _projectOption = false; // declare show project option variable
  
  // holds the selected option from the dropdown menu's
  String? _selectedBlock1Option;
  String? _selectedBlock2Option;
  String? _selectedProjectOption;

  List<List<dynamic>> _data = []; // declare list to store data to be ouputted 
  List<String> block1Option = []; // List to store block1 option
  List<String> projDropdown = []; // List to store Project options
  List<String> block2Option = []; // list to store block2 option

  // List of colours for the output data
  final List<Color> columnColors = [
  Colors.red.shade100,
  Colors.green.shade100,
  Colors.blue.shade100,
  Colors.orange.shade100,
  Colors.purple.shade100,
  Colors.teal.shade100,
  Colors.yellow.shade100,
  Colors.pink.shade100,
  Colors.indigo.shade100,
  Colors.cyan.shade100,
  Colors.lime.shade100,
  Colors.brown.shade100,
  Colors.amber.shade100,
  Colors.deepOrange.shade100,
  Colors.lightGreen.shade100,
  Colors.deepPurple.shade100,
  Colors.grey.shade300, // subtle neutral
];
  
  // Loads CSV files to fill in the data for dropdown menus (for block1, block2 and project options)
  Future<void> _loadDropdownData() async {
      _projectOption = false;
      String block1CSV = "assets/$course/${year}_options1.csv"; // loads Block1 csv (using string interpolation to locate correct csv)
      String block2CSV = "assets/$course/${year}_options2.csv"; // loads block2 csv (same method)
      List<String> extractedOptions1 = []; 
      List<String> extractedOptions2 = [];
      List<String> project = [];
      String projectCSV = "";

      // if statement checks to if the conditions are met to require the extra "project option" dropdown
      if (course == "Cyber Security" && year == "year3") {
      _projectOption = true;
      projectCSV = "assets/$course/${year}_project.csv"; 
       }

      try {
        // Load core options from block 1
        final mainData1 = await rootBundle.loadString(block1CSV);
        List<List<dynamic>> mainCsv1 = const CsvToListConverter().convert(mainData1);
        extractedOptions1 = mainCsv1.map((row) => row[1].toString()).toList();
        _showExtraDropdown1 = true;

        } catch (e) {
        print('Error loading CSV file: $e');
        _showExtraDropdown1 = false;
       
      }

      try {
        //loads core options from block2
        final mainData2 = await rootBundle.loadString(block2CSV);
        List<List<dynamic>> mainCsv2 = const CsvToListConverter().convert(mainData2);
        extractedOptions2 = mainCsv2.map((row) => row[1].toString()).toList();
        _showExtraDropdown2 = true;

      } catch (e) {
        print('Error loading CSV file: $e');
        _showExtraDropdown2 = false;
      }

        // Load project options if needed (forced error in the event)
        if (_projectOption) {
          final projectData = await rootBundle.loadString(projectCSV);
          List<List<dynamic>> projectCsv = const CsvToListConverter().convert(projectData);
          project = projectCsv.map((row) => row[1].toString()).toList();
        }

        // Update UI
        setState(() {
          block1Option = extractedOptions1;
          block2Option = extractedOptions2;
          if (_projectOption == true) {
            projDropdown = project;
          }
        });
      
    }

  // Sorts data by due date (SetState will refresh the data on screen)
  void _sortDataByDueDate() {

  var dateFormat = DateFormat("dd/MM/yyyy");

  // Store the first item (to keep it fixed at the top)
  List<List<dynamic>> fixedItem = [_data.isNotEmpty ? _data[0] : []];

  // Creates lists for both valid and invalid rows
  List<List<dynamic>> validRows = [];
  List<List<dynamic>> invalidRows = [];

  for (var row in _data.sublist(1)) {  // Skip the first item (this is as it is the header row containing the label for the data in each column)
    String date = row.length > 6 ? row[6].toString() : '';  // Get the date from column 7 (index 6)

    try {
      if (date.isNotEmpty) {

        // Try parsing the date
        // ignore: unused_local_variable
        DateTime dateTime = dateFormat.parse(date);
        validRows.add(row);  // Add to valid list if date is valid
      } else {
        invalidRows.add(row);  // If no date, add to invalid list
      }
    } catch (e) {
      invalidRows.add(row); // If error parsing date, treat it as invalid
    }
  }

  // Now sort valid rows by date (column 7)
  validRows.sort((a, b) {
    String dateA = a.length > 6 ? a[6].toString() : '';  // Column 7 (index 6)
    String dateB = b.length > 6 ? b[6].toString() : '';  // Column 7 (index 6)

    try {
      DateTime dateTimeA = dateFormat.parse(dateA);
      DateTime dateTimeB = dateFormat.parse(dateB);
      return dateTimeA.compareTo(dateTimeB);  // Compare valid dates
    } catch (e) {
      return 0; // If error parsing date, treat as equal
    }
  });

   invalidRows.sort((a, b) {
    String valueA = a.length > 1 ? a[1].toString().toLowerCase() : '';
    String valueB = b.length > 1 ? b[1].toString().toLowerCase() : '';
    return valueA.compareTo(valueB);  // Compare alphabetically
  });

  // Combine fixed item, valid rows, and invalid rows
  setState(() {
    _data = fixedItem + validRows + invalidRows;  // Keep first item fixed, then valid rows, then invalid rows
  });
}

  // Sorts data alphabetically (this will order the data by module)
  void _sortDataAlphabetically() {

  // Ensure the first item stays fixed
  List<List<dynamic>> fixedItem = [_data.isNotEmpty ? _data[0] : []];

  // adds all remaining data outside the first item into a "sortable list"
  List<List<dynamic>> sortableData = _data.length > 1 ? _data.sublist(1) : [];

  // Sort the remaining data based on index 1 (Module Name)
  sortableData.sort((a, b) {
    String valueA = a.length > 1 ? a[1].toString().toLowerCase() : '';
    String valueB = b.length > 1 ? b[1].toString().toLowerCase() : '';
    return valueA.compareTo(valueB);  // Compare alphabetically
  });

  // Combine the fixed first item with the sorted data
  setState(() {
    _data = fixedItem + sortableData;  // Keep the first item fixed, then add sorted rows
  });
}

  // Add's rows to _data from a different CSV (based on the options chosen in the optional module dropdowns) and remove any previosuly selected options from _data
  void _addRowFromAnotherCSV(String option, String version) async {
  
  try {
    // Load the master CSV file
    final rawData = await rootBundle.loadString("assets/Master_Module.csv");
    List<List<dynamic>> masterCsvData = const CsvToListConverter().convert(rawData);

    // Load options CSV to get the options
    final optionsData = await rootBundle.loadString("assets/$course/${year}_$version.csv");
    List<List<dynamic>> optionsCsv = const CsvToListConverter().convert(optionsData);

    // The below section is used to ensure that there is no duplicate options in _data.

    // Make a list of all data in Master_Module that matches the options (This was done to ensure there was ony one selected option at any time in _data)
    List<List<dynamic>> matchingRows = optionsCsv.where((row) =>
        row.any((cell) => cell.toString().toLowerCase() == option.toLowerCase())
    ).toList();

    // If there are matching rows remove them from _data (if this is the option has been selected already and is being changed this will always occur)
    if (matchingRows.isNotEmpty) {
      setState(() {
        // Remove any previously selected options from _data
        _data.removeWhere((row) =>
            optionsCsv.any((csvRow) =>
                row[1].toString().toLowerCase() == csvRow[1].toString().toLowerCase()
            )
        );
        
        //The below section is used in order to find the matching assessments in Master_Module.csv to match the selected module from the dropdown.

        // Find matching rows in the master CSV based on the first column (column 1) of options csv
        for (var matchingRow in matchingRows) {
          String optionColumn1 = matchingRow[0].toString();  // Get the value from column 1 in options.csv

          // Find all corresponding rows in the master CSV where column 1 matches
          List<List<dynamic>> matchedMasterRows = masterCsvData.where((masterRow) =>
              masterRow[0].toString().toLowerCase() == optionColumn1.toLowerCase()
          ).toList();

          // Add all matching rows from the master CSV to _data
          for (var matchedRow in matchedMasterRows) {
            _data.add(matchedRow);  // Add each matching row to _data
          }

          if (matchedMasterRows.isEmpty) {
            print("No matching row found in master CSV for: $optionColumn1");
          }
        }
      });
    } else {
      print("No matching row found in options for: $option");
    }
  } catch (e) {
    print('Error loading second CSV file: $e');
  }
}

  // Reset the options dropdowns to null (prevents them showing previously selected data in the event a new year/course is selected)
  void _resetDropdownSelections() {
  
  // setState will refresh the screen
  setState(() {
    _selectedBlock1Option = null;
    _selectedBlock2Option = null;
    _selectedProjectOption = null;

    block1Option = [];
    block2Option = [];
    projDropdown = [];
  });
}

  //loads the base csv file containing core modules for the respective year and course 
  void _loadCSV(String course, String year) async { 
    _resetDropdownSelections(); // Clear selections and dropdown data

  // checks if the selected year is 2 or 3 - this is as extra dropdowns will need to be created 
  if (year == "year2" || year == "year3") {
    _loadDropdownData();

    // Ensures all non-relevant dropdowns are made invisible again
  } else {
    setState(() {
      _showExtraDropdown1 = false;
      _showExtraDropdown2 = false;
      _projectOption = false;
    });
  }

    String course_data = "assets/" + course;
    String year_data = course_data + "/" + year + ".csv"; // Using string concatenation to locate the correct CSV

    try {
      final rawData = await rootBundle.loadString(year_data);
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData); // Convert content of csv into a list

      // Load Master_Module.csv
      final masterRaw = await rootBundle.loadString('assets/Master_Module.csv');
      List<List<dynamic>> masterData = const CsvToListConverter().convert(masterRaw); //convert content of Master_Module.csv

      // Create a list to hold matched rows
      List<List<dynamic>> matchedRows = [];

      //stores the first item in Master_Module.csv (this is the header row that details the content of each column)
      if (masterData.isNotEmpty) {
        matchedRows.add(masterData[0]);
      }

      // fifth column in listData is the identifier (module code)
      for (var row in listData) {
        final keyword = row[4].toString().toLowerCase();

        // Find matches in Master_Module.csv where the KeyWord is mentioned
        final matches = masterData.where((masterRow) =>
          masterRow.any((cell) =>
            cell.toString().toLowerCase() == keyword
          )
        );

      matchedRows.addAll(matches); // add all matches to the matchedRows Lissst
    }

      setState(() {
        _data = matchedRows; // Update the _data list with the matchedRows data
      });
    } catch (e) { //catch any error loading a CSV to prevent the program from failing in the event a year is selected but not a course (or vice versa)
      print('Error loading CSV file: $e');
    }
  }

  @override
  Widget build(BuildContext context) { // Main webpage build
  // Safely handle empty _data list
  final List<dynamic> headerRow = _data.isNotEmpty ? _data[0] : []; // Presets HeaderRow as the first item in _data (as long as _data isn't empty)
  final List<List<dynamic>> dataRows = _data.length > 1 ? _data.sublist(1) : []; //return a new list skipping the 1st index (as this is the header)
  
  final screenWidth = MediaQuery.of(context).size.width; // gain the screen size of the device

  // Determine columns to show based on screen width
  List<int> columnsToShow;
  
  if (screenWidth < 400) {
    // very small screens (e.g phone), show only columns 1, 6, and 7
    columnsToShow = [1, 5, 6];
  } else if (screenWidth < 600) {
    // Small screen size (e.g ipad), show columns 1, 6, 7, and a couple more
    columnsToShow = [0, 1, 5, 6];
  } else if (screenWidth < 900) {
    // Medium screen (e.g laptop), show more columns like 0, 1, 2, 6, 7, 8
    columnsToShow = [0, 1, 2, 5, 6, 7];
  } else {
    // For larger screens (e.g desktop monitor), show all columns
    columnsToShow = List.generate(headerRow.length, (index) => index);
  }

    return Scaffold(
      backgroundColor: _themeColor, // set the screen colour
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            
            
            Padding(
              padding: const EdgeInsets.all(8.0),

              child: DropdownMenu( //Dropdwon widget to select course
                dropdownMenuEntries: <DropdownMenuEntry<String>>[ 
                  DropdownMenuEntry(value: "Computer science", label: 'Computer Science'),
                  DropdownMenuEntry(value: "Cyber Security", label: 'Cyber Security and Forensic Computing'),
                  DropdownMenuEntry(value: "Computing", label: "Computing"),
                  DropdownMenuEntry(value: "Software", label: "Software Engineering"),
                  DropdownMenuEntry(value: "Data Science", label: "Data Science and Analytics"),
                  DropdownMenuEntry(value: "Networks", label: "Computer Networks"),
                  DropdownMenuEntry(value: "Network Security", label: "Computer Networks and Security"),
                ],
                onSelected: (String? value) {
                  if (value != null) {
                    setState(() {
                      course = value; // stores the chosen course in the global course variable 
                    });
                    _loadCSV(course, year); // Attempts _loadCSV (_loadCSV will catch an error and not run if year has not been selected)
                  }
                },
                hintText: "Select your course: ",
                enableFilter: true,
                enableSearch: true,
                width: 250,
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(8.0),
              
              child: DropdownMenu( //dropdown widet to select year
                dropdownMenuEntries: <DropdownMenuEntry<String>>[ 
                  DropdownMenuEntry(value: "year1", label: 'Level 4 (year 1)'),
                  DropdownMenuEntry(value: "year2", label: 'Level 5 (year 2)'),
                  DropdownMenuEntry(value: "year3", label: 'Level 6 (year 3)'),
                ],
                onSelected: (String? value) {
                  if (value != null) {
                    setState(() {
                      year = value; // stores the chosen year in the global year variable 
                    });
                    _loadCSV(course, year); // Attempts _loadCSV (_loadCSV will catch an error and not run if course has not been selected)
                  }
                },
                hintText: "Select your year: ",
                enableFilter: true,
                enableSearch: true,
                width: 250,
              ),
            ),


            // Extra dropdown appears only for year 2 and 3 (for block 1)
            Visibility(
              visible: _showExtraDropdown1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu(
                  key: ValueKey('$course-$year-block1-${_selectedBlock1Option ?? ''}'),
                  dropdownMenuEntries: block1Option.map((value) {
                    return DropdownMenuEntry(value: value, label: value);
                  }).toList(),
                  initialSelection: _selectedBlock1Option,
                  onSelected: (String? value) {
                    if (value != null) {              
                      _addRowFromAnotherCSV(value,"options1");
                      print("Extra option selected: $value");
                      }
                  },
                  hintText: "Select an block 1 option",
                  enableFilter: true,
                  enableSearch: true,
                  width: 250,
                ),
              ),
            ),

            // Extra dropdown appears only for year 2 and 3 (for block 2)
            Visibility(
              visible: _showExtraDropdown2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu(
                  key: ValueKey('$course-$year-block2-${_selectedBlock2Option ?? ''}'),
                  dropdownMenuEntries: block2Option.map((value) {
                    return DropdownMenuEntry(value: value, label: value);
                  }).toList(),
                  initialSelection: _selectedBlock2Option,
                  onSelected: (String? value) {
                    if (value != null) {              
                      _addRowFromAnotherCSV(value,"options2");
                      print("Extra option selected: $value");
                      }
                  },
                  hintText: "Select block 2 option",
                  enableFilter: true,
                  enableSearch: true,
                  width: 250,
                ),
              ),
            ),
            
            // extra dropdown to choose project for cyber
            Visibility(
              visible: _projectOption,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu(
                  key: ValueKey('$course-$year-project-${_selectedProjectOption ?? ''}'),
                  dropdownMenuEntries: projDropdown.map((value) {
                    return DropdownMenuEntry(value: value, label: value);
                  }).toList(),
                  initialSelection: _selectedProjectOption,
                  onSelected: (String? value) {
                    if (value != null) {              
                      _addRowFromAnotherCSV(value,"project");
                      print("Extra option selected: $value");
                      }
                  },
                  hintText: "Select Project option",
                  enableFilter: true,
                  enableSearch: true,
                  width: 250,
                ),
              ),
            ),


             //  buttons for Due date and module sorting methods
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _sortDataByDueDate,
                  child: Text('Sort by Due Date'),
                ),

                ElevatedButton(
                  onPressed: _sortDataAlphabetically,
                  child: Text('Sort by Module'),
                ),
              ],
            ),
            
            // Always-visible header row
          if (_data.isNotEmpty) // Ensure that the data is not empty
            Container(
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                children: List.generate(columnsToShow.length, (colIndex) {
                  return Expanded(
                    child: Text(
                      headerRow[columnsToShow[colIndex]].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Only display the ListView.builder if there are data rows
          if (dataRows.isNotEmpty) 

            // ListView.builder to ouput all the data from dataRows
            Expanded(
              child: ListView.builder(
                itemCount: dataRows.length,
                itemBuilder: (context, index) {
                  final row = dataRows[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      children: List.generate(
                        columnsToShow.length,
                        (colIndex) {
                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              color: columnColors[colIndex % columnColors.length],
                              child: Text(
                                row[columnsToShow[colIndex]].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
