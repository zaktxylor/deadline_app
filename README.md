
# Deadline Tracking Application

A Flutter-based mobile application designed to help students keep track of their module deadlines based on their **course** and **year** of study. The application dynamically loads content from CSV files and displays assessments in an organized and user-friendly interface.

---

## Features

- Select your **course** and **year** using dropdown menus.
- Automatically displays relevant **core module assessments**.
- For **year 2 and 3**, additional dropdowns appear for selecting **optional modules**.
- Dynamic loading and filtering of assessments from CSV files.
- Sort deadlines by **due date** or **module name**.
- Responsive design for mobile, tablet, and desktop screen sizes.
- Smooth CSV parsing using the `csv` Flutter package.

---

## File Structure

```plaintext
assets/
├── Computer Science/
│   ├── year1.csv
│   ├── year2.csv
│   ├── year2_options1.csv
│   ├── year2_options2.csv
│   └── ...
├── Cyber Security/
│   ├── year3_project.csv
│   └── ...
├── Master_Module.csv
lib/
└── main.dart
```

---

## How It Works

1. **Course & Year Selection**:  
   The user selects their course and academic year from dropdown menus.

2. **CSV Loading**:  
   Based on selections, the app loads a core CSV (`yearX.csv`) to identify module codes.

3. **Assessment Mapping**:  
   Module codes are matched to the central `Master_Module.csv` to display relevant deadlines.

4. **Optional Modules** (Years 2 & 3):
   - Two additional dropdowns allow users to select optional modules.
   - The app fetches corresponding assessments from `yearX_options1.csv` and `yearX_options2.csv`.
   - If applicable (e.g. Cyber Security Year 3), a **project selection** dropdown is also displayed.

5. **Dynamic Updates**:
   - Users can change their selections at any time, triggering fresh data loads and screen refreshes.
   - Assessments are displayed in a scrollable, responsive table.

---

## Requirements

- Flutter 3.x or later
- Dart 3.x or later
- Assets and CSVs structured correctly (see above)

---

## Dependencies

- [`csv`](https://pub.dev/packages/csv) – For parsing CSV files
- [`intl`](https://pub.dev/packages/intl) – For handling and formatting dates
- [`flutter/material.dart`] – Core UI framework

Install dependencies with:

```bash
flutter pub get
```

---

## To Run the App

1. Ensure Flutter is installed and set up.
2. Clone the repo and open it in your preferred IDE.
3. Add your `assets` folder and ensure it’s declared in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## Developer Notes

- Core logic is handled in `main.dart` within a single `StatefulWidget`.
- The first row of any loaded CSV is assumed to be the **header** and is kept fixed during sorting.
- Sorting functions (`_sortDataByDueDate`, `_sortDataAlphabetically`) keep the header row in place while sorting the rest.
- All module/assessment data displayed is derived from a centralized `Master_Module.csv` to ensure consistency.

---

## TODO (Optional Enhancements)

- Add local notifications/reminders for upcoming deadlines.
- Persist user selections using shared preferences.
- Add export to calendar (e.g., Google Calendar).
- Integrate user authentication for personalized experiences.

---

## License

This project is for educational purposes. License terms TBD.
