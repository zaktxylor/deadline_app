import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  var _themeColor = Colors.white;
  var course = '';
  var year = '';
  bool _showExtraDropdown = false; 
  bool _projectOption = false;
  String? _selectedBlock1Option;
  String? _selectedBlock2Option;
  String? _selectedProjectOption;

  List<List<dynamic>> _data = [];
  List<String> dropdownItems = []; // List to store dropdown options
  List<String> projDropdown = [];
  List<String> block2_dropdown = [];

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

  Future<void> _loadDropdownData() async {
      _projectOption = false;
      String block1CSV = "assets/$course/${year}_options1.csv";
      String block2CSV = "assets/$course/${year}_options2.csv";
      List<String> extractedOptions1 = [];
      List<String> extractedOptions2 = [];
      List<String> project = [];
      String projectCSV = "";

      if (course == "Cyber Security" && year == "year3") {
      _projectOption = true;
      projectCSV = "assets/$course/${year}_project.csv"; // <-- make sure this matches actual file
       }

      try {
        // Load main options from block 1
        final mainData1 = await rootBundle.loadString(block1CSV);
        List<List<dynamic>> mainCsv1 = const CsvToListConverter().convert(mainData1);
        extractedOptions1 = mainCsv1.map((row) => row[1].toString()).toList();

        } catch (e) {
        print('Error loading CSV file: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading dropdown options: $e'),
        ));
      }

      try {
        //loads options from block2
        final mainData2 = await rootBundle.loadString(block2CSV);
        List<List<dynamic>> mainCsv2 = const CsvToListConverter().convert(mainData2);
        extractedOptions2 = mainCsv2.map((row) => row[1].toString()).toList();

      } catch (e) {
        print('Error loading CSV file: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading dropdown options: $e'),
        ));
      }

        // Load project options if needed
        if (_projectOption) {
          final projectData = await rootBundle.loadString(projectCSV);
          List<List<dynamic>> projectCsv = const CsvToListConverter().convert(projectData);
          project = projectCsv.map((row) => row[1].toString()).toList();
        }

        // Update UI
        setState(() {
          dropdownItems = extractedOptions1;
          block2_dropdown = extractedOptions2;
          if (_projectOption == true) {
            projDropdown = project;
          }
        });
      
    }

  void _sortDataByDueDate() {
  var dateFormat = DateFormat("dd/MM/yyyy");

  // Store the first item (to keep it fixed at the top)
  List<List<dynamic>> fixedItem = [_data.isNotEmpty ? _data[0] : []];

  // Separate the data into valid and invalid date lists, skipping the first item
  List<List<dynamic>> validRows = [];
  List<List<dynamic>> invalidRows = [];

  for (var row in _data.sublist(1)) {  // Skip the first item
    String date = row.length > 6 ? row[6].toString() : '';  // Get the date from column 7 (index 6)

    try {
      if (date.isNotEmpty) {
        // Try parsing the date
        DateTime dateTime = dateFormat.parse(date);
        validRows.add(row);  // Add to valid list if date is valid
      } else {
        invalidRows.add(row);  // If no date, add to invalid list
      }
    } catch (e) {
      // If error parsing date, treat it as invalid
      invalidRows.add(row);
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

  void _sortDataAlphabetically() {
  // Ensure the first item stays fixed
  List<List<dynamic>> fixedItem = [_data.isNotEmpty ? _data[0] : []];

  // Sort the rest of the items by the value in index 1 (alphabetically)
  List<List<dynamic>> sortableData = _data.length > 1 ? _data.sublist(1) : [];

  // Sort the remaining data based on index 1 (alphabetically)
  sortableData.sort((a, b) {
    String valueA = a.length > 1 ? a[1].toString().toLowerCase() : '';
    String valueB = b.length > 1 ? b[1].toString().toLowerCase() : '';
    return valueA.compareTo(valueB);  // Compare alphabetically
  });

  // Combine the fixed first item with the sorted data
  setState(() {
    _data = fixedItem + sortableData;  // Keep the first item fixed, then sorted rows
  });
}

  void _addRowFromAnotherCSV(String option1, String version) async {
  try {
    // Load the master CSV file
    final rawData = await rootBundle.loadString("assets/Master_Module.csv");
    List<List<dynamic>> masterCsvData = const CsvToListConverter().convert(rawData);

    // Load options CSV to get the options
    final optionsData = await rootBundle.loadString("assets/$course/${year}_$version.csv");
    List<List<dynamic>> optionsCsv = const CsvToListConverter().convert(optionsData);

    // Search for rows that match the selected module in the csv(case-insensitive)
    List<List<dynamic>> matchingRows = optionsCsv.where((row) =>
        row.any((cell) => cell.toString().toLowerCase() == option1.toLowerCase())
    ).toList();

    // If there are matching rows, proceed with replacing the old ones
    if (matchingRows.isNotEmpty) {
      setState(() {
        // Remove any previously selected options that came from options
        _data.removeWhere((row) =>
            optionsCsv.any((csvRow) =>
                row[1].toString().toLowerCase() == csvRow[1].toString().toLowerCase()
            )
        );

        // Find matching rows in the master CSV based on the second column (column 2) of options csv
        for (var matchingRow in matchingRows) {
          String optionColumn2 = matchingRow[0].toString();  // Get the value from column 2 in year2_options1.csv

          // Find all corresponding rows in the master CSV where column 2 matches
          List<List<dynamic>> matchedMasterRows = masterCsvData.where((masterRow) =>
              masterRow[0].toString().toLowerCase() == optionColumn2.toLowerCase()
          ).toList();

          // Add all matching rows from the master CSV to _data
          for (var matchedRow in matchedMasterRows) {
            _data.add(matchedRow);  // Add each matching row
          }

          if (matchedMasterRows.isEmpty) {
            print("No matching row found in master CSV for: $optionColumn2");
          }
        }
      });
    } else {
      print("No matching row found in options for: $option1");
    }
  } catch (e) {
    print('Error loading second CSV file: $e');
  }
}

  void _resetDropdownSelections() {
  setState(() {
    _selectedBlock1Option = null;
    _selectedBlock2Option = null;
    _selectedProjectOption = null;

    dropdownItems = [];
    block2_dropdown = [];
    projDropdown = [];
  });
}

  void _loadCSV(String course, String year) async { //loads the base csv file containing core modules for the respective year and course 
    _resetDropdownSelections(); // Clear selections and dropdown data

  if (year == "year3" && course == "Cyber Security"){
    setState(() {
      _showExtraDropdown = true;
      _projectOption = true;
    });
    _loadDropdownData();
  }

  else if (year == "year2" || year == "year3") {
    setState(() {
      _showExtraDropdown = true;
      _projectOption = false;
    });
    _loadDropdownData();

  } else {
    setState(() {
      _showExtraDropdown = false;
      _projectOption = false;
    });
  }

    var course_data = "assets/" + course;
    var year_data = course_data + "/" + year + ".csv";

    try {
      final rawData = await rootBundle.loadString(year_data);
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

      // Load the master CSV
    final masterRaw = await rootBundle.loadString('assets/master_module.csv');
    List<List<dynamic>> masterData = const CsvToListConverter().convert(masterRaw);

    // Create a list to hold matched rows
    List<List<dynamic>> matchedRows = [];

    if (masterData.isNotEmpty) {
      matchedRows.add(masterData[0]);
    }

    // Assuming first column in listData is the identifier (e.g., module code)
    for (var row in listData) {
      final keyword = row[4].toString().toLowerCase();

      // Find matches in masterData where any column contains the keyword
      final matches = masterData.where((masterRow) =>
        masterRow.any((cell) =>
          cell.toString().toLowerCase() == keyword
        )
      );

      matchedRows.addAll(matches);
    }

      setState(() {
        _data = matchedRows; // Update the _data list with the CSV data
      });
    } catch (e) {
      print('Error loading CSV file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely handle empty _data list
  final List<dynamic> headerRow = _data.isNotEmpty ? _data[0] : [];
  final List<List<dynamic>> dataRows = _data.length > 1 ? _data.sublist(1) : [];
  
  final screenWidth = MediaQuery.of(context).size.width;
  // Determine columns to show based on screen width
  List<int> columnsToShow;
  
  if (screenWidth < 400) {
    // For very small screens (e.g., phone), show only columns 1, 6, and 7
    columnsToShow = [1, 5, 6];
  } else if (screenWidth < 600) {
    // Small screen size, show columns 1, 6, 7, and a couple more
    columnsToShow = [0, 1, 5, 6];
  } else if (screenWidth < 900) {
    // Medium screen, show more columns like 0, 1, 2, 6, 7, 8
    columnsToShow = [0, 1, 2, 5, 6, 7];
  } else {
    // For larger screens, show all columns
    columnsToShow = List.generate(headerRow.length, (index) => index);
  }

    return Scaffold(
      backgroundColor: _themeColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownMenu(
                dropdownMenuEntries: <DropdownMenuEntry<String>>[ //Dropdwon widget for course
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
                      course = value;
                    });
                    _loadCSV(course, year);
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
              child: DropdownMenu(
                dropdownMenuEntries: <DropdownMenuEntry<String>>[ //dropdown widet for year
                  DropdownMenuEntry(value: "year1", label: 'Level 5 (year 1)'),
                  DropdownMenuEntry(value: "year2", label: 'Level 6 (year 2)'),
                  DropdownMenuEntry(value: "year3", label: 'Level 7 (year 3)'),
                ],
                onSelected: (String? value) {
                  if (value != null) {
                    setState(() {
                      year = value;
                    });
                    _loadCSV(course, year);
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
              visible: _showExtraDropdown,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu(
                  key: ValueKey('$course-$year-block1-${_selectedBlock1Option ?? ''}'),
                  dropdownMenuEntries: dropdownItems.map((value) {
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
              visible: _showExtraDropdown,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu(
                  key: ValueKey('$course-$year-block2-${_selectedBlock2Option ?? ''}'),
                  dropdownMenuEntries: block2_dropdown.map((value) {
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
