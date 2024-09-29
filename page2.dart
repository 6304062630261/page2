import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vongola/database/db_manage.dart';
import 'package:intl/intl.dart';

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String selectedButton = 'Day';
  String selectedIcon = 'Pie';
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  List<PieChartSectionData> pieChartSections = [];
  List<Map<String, dynamic>> statusExpenses = [];
  List<Map<String, dynamic>> selectedDateExpenses = [];
  DateTime? selectedDate;
  Set<DateTime> markedDates = {};
  DateTime? currentSelectedDate; // ประกาศตัวแปรเก็บวันที่เลือก



  final Map<String, Color> typeToColor = {
    'Food': Colors.red,
    'Travel expenses': Colors.lightGreenAccent,
    'Water bill': Colors.lightBlueAccent,
    'Electricity bill': Colors.yellow,
    'House cost': Colors.deepOrangeAccent,
    'Car fare': Colors.deepPurpleAccent,
    'Gasoline cost': Colors.orangeAccent,
    'Medical expenses': Colors.indigo,
    'Beauty expenses': Colors.pinkAccent,
    'Cost of equipment': Colors.blue.shade100,
    'Other': Colors.teal.shade400,


  };
  final Map<String, String> typeImage = {
    'Food': 'assets/food.png',
    'Travel expenses':'assets/travel_expenses.png',
    'Water bill': 'assets/water_bill.png',
    'Electricity bill': 'assets/electricity_bill.png',
    'House cost': 'assets/house.png',
    'Car fare': 'assets/car.png',
    'Gasoline cost': 'assets/gasoline_cost.png',
    'Medical expenses': 'assets/medical.png',
    'Beauty expenses': 'assets/beauty.png',
    'Other': 'assets/other.png',
    'IC' :'assets/money.png'

  };

  String formatCurrency(double value) {
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)}M'; // Format for millions
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(1)}k'; // Format for thousands
    }
    return value.toString(); // Return as is for values less than a thousand
  }


  @override
  void initState() {
    super.initState();
    selectedButton = 'Day'; // เริ่มต้นที่ Day
    selectedIcon = 'Pie'; // เริ่มต้นที่ Pie Chart
    _show_DonutChart(context); // เรียกใช้ Pie Chart สำหรับ Day
     // เรียก Status สำหรับ Day
    _fetch_Mark_Dates();


  }

  Future<void> _fetch_Mark_Dates() async {
    // ดึงข้อมูลวันที่ที่มีการบันทึกจากฐานข้อมูล
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
      SELECT DISTINCT DATE(date_user) as date_user 
      FROM Transactions
      '''
    );

    setState(() {
      markedDates = result.map((data) => DateTime.parse(data['date_user'])).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Static Chart')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // ส่วนการแสดงปฏิทินและไอคอน
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // เพิ่ม Padding ซ้ายและขวา
                child: TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2100, 1, 1),
                  focusedDay: DateTime.now(),
                    availableCalendarFormats: const {
                      CalendarFormat.month : 'Month'
                    },
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      print("________[ s e l e c t  d a y ]__________");
                      print(selectedDay);
                      DateTime dateOnly = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                      print("Selected date dateonly: $dateOnly");
                      _showDateDetailsDialog(dateOnly);
                    });
                  },
                  // ใช้ CalendarBuilders ในการกำหนดวันที่มีการบันทึก
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      // ตรวจสอบวันที่มีข้อมูลใน markedDates
                      if (markedDates.any((markedDate) =>
                      markedDate.year == date.year &&
                          markedDate.month == date.month &&
                          markedDate.day == date.day)) {
                        // แสดงสัญลักษณ์ที่ต้องการ (วงกลมสีแดง) สำหรับวันที่มีข้อมูล
                        print('////');
                        print(markedDates);
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              // สีที่คุณต้องการให้แสดง
                            ),
                          ),
                        );
                      }
                      return null; // ถ้าไม่มีข้อมูลในวันนั้น ไม่แสดงสัญลักษณ์
                    },
                  ),



                ),
              ),
              SizedBox(height: 20),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(
                      Image.asset('assets/pie-chart.png', width: 70, height: 70), // ใช้รูปภาพจาก assets
                      'Pie',
                      Colors.blue,
                      _show_DonutChart,
                    ),
                    _buildIconButton(
                      Image.asset('assets/notes.png', width: 70, height: 70), // ใช้รูปภาพจาก assets
                      'Status',
                      Colors.green,
                      _show_Status_Expense,
                    ),
                    _buildIconButton(
                      Image.asset('assets/compare.png', width: 70, height: 70), // ใช้รูปภาพจาก assets
                      'Bar',
                      Colors.orange,
                      _show_BarChart,
                    ),
                  ],
                ),
              ),


              SizedBox(height: 20),
              // ปุ่ม Day, Month, Year
              Padding(
                padding: const EdgeInsets.only(right: 20.0), // กำหนดให้ห่างจากขอบขวา 20
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // จัดปุ่มไปทางขวา
                  children: [
                    _buildPeriodButton('Day'),
                    SizedBox(width: 0),
                    // ระยะห่างระหว่างปุ่ม
                    _buildPeriodButton('Month'),
                    SizedBox(width: 0), // ระยะห่างระหว่างปุ่ม
                    _buildPeriodButton('Year'),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // ส่วนแสดงกราฟ Pie Chart
              if (selectedIcon == 'Pie') _build_DonutChart(),
              // ส่วนแสดงกราฟ Bar Chart
              if (selectedIcon == 'Bar') _build_BarChart(),
              if (selectedIcon == 'Status') _build_StatusList()

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(Widget iconWidget, String iconType, Color color, Function onPressed) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIcon = iconType;
        });
        onPressed(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedIcon == iconType ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: Colors.black26, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // เพิ่ม padding ซ้ายและขวา
        child: iconWidget,
      ),
    );
  }

  Widget _buildIndicator() {
    return Column(
      children: pieChartSections.map((section) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: section.color, // สีของ Indicator ตาม PieChartSectionData
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${section.title.split('\n')[0]}: ${formatCurrency(section.value)}', // แสดงชื่อและมูลค่า
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _build_DonutChart() {
    // ข้อความ Chart และ Show Expenses อยู่ด้านบนก่อน if
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // กำหนดระยะห่างจากขอบซ้ายและขวา 20
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความให้อยู่ด้านซ้าย
        children: [
          // ข้อความ Chart และ Show Expenses
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // จัดให้อยู่ชิดซ้าย
            children: [
              Text(
                'Chart',
                style: TextStyle(
                  fontSize: 24, // ขนาดตัวอักษรใหญ่
                  fontWeight: FontWeight.bold, // ทำให้ตัวหนา
                ),
              ),
              Text(
                'Show Expenses',
                style: TextStyle(
                  fontSize: 12, // ขนาดตัวอักษรเล็กกว่า
                ),
              ),
            ],
          ),
          SizedBox(height: 10), // เพิ่มระยะห่างระหว่างข้อความกับ Pie Chart

          // เช็คเงื่อนไขว่าถ้าไม่มีข้อมูลใน pieChartSections
          if (pieChartSections.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50), // เพิ่มระยะห่างจากข้างบน
                  Image.asset(
                    'assets/Zzz.png', // ใส่ path รูปภาพที่คุณต้องการ
                    width: 100, // กำหนดขนาดความกว้างของรูป
                    height: 100, // กำหนดขนาดความสูงของรูป
                    fit: BoxFit.cover, // กำหนดการแสดงผลรูปภาพ
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Container(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildIndicator(), // แสดง Indicator ใต้ Pie Chart
              ],
            ),
        ],
      ),
    );
  }

  Widget _build_BarChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compare',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Show Expenses',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (totalIncome == 0.0 && totalExpense == 0.0)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/Zzz.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Container(
                  height: 300,
                  width: 300,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1),
                          left: BorderSide(color: Colors.transparent, width: 0),
                          right: BorderSide(color: Colors.transparent, width: 0),
                          top: BorderSide(color: Colors.transparent, width: 10),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: totalExpense,
                              width: 30,
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: totalIncome,
                              width: 30,
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '- ${formatCurrency(totalExpense)}฿',
                            style: TextStyle(fontSize: 20, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '+ ${formatCurrency(totalIncome)}฿',
                            style: TextStyle(fontSize: 20, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _build_StatusList() {
    double totalIncome_Status = 0;
    double totalExpense_Status = 0;

    // คำนวณรายรับและรายจ่ายทั้งหมด
    statusExpenses.forEach((transaction) {
      if (transaction['isExpense']) {
        totalExpense_Status += transaction['amount'];
      } else {
        totalIncome_Status += transaction['amount'];
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Show income and expense records',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // ส่วนแสดงยอดรวม Income และ Expenses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Income', style: TextStyle(color: Colors.green)),
              Text('${formatCurrency(totalIncome_Status)} THB', style: TextStyle(color: Colors.green)),
            ],


          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expenses', style: TextStyle(color: Colors.red)),
              Text('${formatCurrency(totalExpense_Status)} THB', style: TextStyle(color: Colors.red)),
            ],
          ),
          SizedBox(height: 50),

          if (statusExpenses.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/Zzz.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: statusExpenses.length,
              itemBuilder: (context, index) {
                final transaction = statusExpenses[index];
                final type = transaction['type'];
                final imagePath = typeImage[type] ?? 'assets/other.png';
                final amount = formatCurrency(transaction['amount']);
                final isExpense = transaction['isExpense'];
                final amountText = isExpense ? '-$amount THB' : '+$amount THB';
                final amountColor = isExpense ? Colors.red : Colors.green;

                return ListTile(
                  leading: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  title: Text(type == 'IC' ? 'Income' : type), // เพิ่มเงื่อนไขที่นี่
                  trailing: Text(
                    amountText,
                    style: TextStyle(color: amountColor),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // สร้างปุ่มเลือกช่วงเวลา (Day, Month, Year)
  TextButton _buildPeriodButton(String label) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedButton = label;
        });
        if (selectedIcon == 'Pie') {
          _show_DonutChart(context); // เรียกฟังก์ชันดึงข้อมูล Pie Chart เมื่อเลือกช่วงเวลา
        } else if (selectedIcon == 'Bar') {
          _show_BarChart(context); // เรียกฟังก์ชันดึงข้อมูล Bar Chart เมื่อเลือกช่วงเวลา
        }else if(selectedIcon=='Status'){
          _show_Status_Expense(context);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color:selectedButton==label ? Colors.blue : Colors.black, // เปลี่ยนสีตัวอักษรเมื่อถูกเลือก
          fontWeight: selectedButton == label ? FontWeight.bold : FontWeight.normal, // เพิ่มความหนาของตัวอักษรเมื่อถูกเลือก
        ),
      ),

    );
  }

  Future<void> _deleteExpense(int id) async {
    int deletedCount = await DatabaseManagement.instance.deleteTransaction(id);

    if (deletedCount > 0) {
      print('Deleted successfully!');

      // อัปเดตลิสต์ selectedDateExpenses
      setState(() {
        selectedDateExpenses.removeWhere((expense) => expense['ID'] == id);
      });
      await _fetch_Mark_Dates();

      // ปิด dialog
      Navigator.of(context).pop();

      // เปิด dialog ใหม่พร้อมข้อมูลที่อัปเดตแล้ว
      _showDateDetailsDialog(currentSelectedDate!);
    } else {
      print('No data deleted.');
    }

    print('Attempting to delete ID---------------: $id');
    print(deletedCount);
  }




  void _showDateDetailsDialog(DateTime date) async {
    currentSelectedDate = date;
    String dateString = date.toIso8601String().split('T')[0];


    await _fetchcalendarDay(dateString);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height; // เอาความสูงของหน้าจอมาใช้
        return AlertDialog(
          title: Text(DateFormat('dd MMM yyyy').format(date.toLocal())),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.7, // จำกัดความสูงของ Dialog ไม่เกิน 70% ของหน้าจอ
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedDateExpenses.isEmpty)
                    Column(
                      children: [
                        Image.asset(
                          'assets/Zzz.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Text('No records for this day', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  else
                    ...selectedDateExpenses.map((expense) {
                      String imagetype = 'assets/beauty.png';

                      // เลือกภาพที่เหมาะสมตามประเภท
                      if (expense['incomeexpense'] == 0) {
                        imagetype = 'assets/wallet_color.png'; // สำหรับ income
                      } else if (expense['type'] == 'Food' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/food.png'; // สำหรับ expense ประเภท Food
                      } else if (expense['type'] == 'Travel expenses' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/travel_expenses.png';
                      } else if (expense['type'] == 'Water bill' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/water_bill.png';
                      } else if (expense['type'] == 'Electricity bill' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/electricity_bill.png';
                      } else if (expense['type'] == 'House cost' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/house.png';
                      } else if (expense['type'] == 'Car fare' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/car.png';
                      } else if (expense['type'] == 'Gasoline cost' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/gasoline_cost.png';
                      } else if (expense['type'] == 'Medical expenses' && expense['incomeexpense'] == 1) {
                        imagetype = 'assets/medical.png';
                      }

                      return Row(
                        children: [
                          Image.asset(
                            imagetype,
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(width: 10), // ระยะห่างระหว่างรูปกับข้อมูล

                          Expanded(
                            child: ListTile(
                              title: Text(
                                expense['incomeexpense'].toString() == '0'
                                    ? 'Income' // ถ้า incomeexpense เป็น 0 จะแสดง "Income"
                                    : '${expense['type']}', // ถ้าเป็น 1 จะแสดง type ปกติ
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amount: ${formatCurrency(expense['amount'])}'),
                                  Text('Memo: ${expense['memo']}'),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_note, color: Colors.blue),
                            onPressed: () {
                              _showEditExpenseDialog(expense['ID_transaction_Primary'], (amount, memo) {
                                // การดำเนินการหลังจากบันทึก
                                _updateExpense(expense['ID_transaction_Primary'], amount, memo);
                              });},
                          ),
                          IconButton(
                              icon: Icon(Icons.close_rounded, color: Colors.red),
                              onPressed: () {
                              _deleteExpense(expense['ID_transaction_Primary']);
                              },
                          ),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }



  void _showEditExpenseDialog(int id, Function(double, String) onSave) {
    TextEditingController amountController = TextEditingController();
    TextEditingController memoController = TextEditingController();

    // ดึงข้อมูลปัจจุบันเพื่อแสดงใน Dialog
    var expense = selectedDateExpenses.firstWhere((expense) => expense['ID_transaction_Primary'] == id);
    amountController.text = expense['amount'].toString();
    memoController.text = expense['memo'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: memoController,
                decoration: InputDecoration(labelText: 'Memo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog โดยไม่แก้ไขอะไร
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // อัพเดตข้อมูล expense ในฐานข้อมูล
                onSave(double.parse(amountController.text), memoController.text); // เรียก onSave เพื่อส่งค่ากลับ
                Navigator.of(context).pop(); // ปิด Dialog หลังแก้ไขข้อมูลเสร็จ
                // เปิด dialog ใหม่เพื่อแสดงข้อมูลอัพเดต
                Future.delayed(Duration(milliseconds: 100), () {
                  _showDateDetailsDialog(currentSelectedDate!);
                  Navigator.of(context).pop();
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _updateExpense(int id, double amount, String memo) async {
    Map<String, dynamic> updatedRow = {
      'ID_transaction': id, // ID ของการทำธุรกรรม
      'amount_transaction': amount, // จำนวนเงินใหม่
      'memo_transaction': memo, // หมายเหตุใหม่
    };

    await DatabaseManagement.instance.updateTransaction(updatedRow); // เรียกใช้งานอัปเดตด้วย Map
    setState(() {
      // อัปเดตข้อมูลในแอพ
      selectedDateExpenses = selectedDateExpenses.map((expense) {
        if (expense['ID_transaction_Primary'] == id) { // ใช้ ID_transaction_Primary แทน
          return {
            ...expense,
            'amount': amount,
            'memo': memo,
          };
        }
        return expense;
      }).toList();

    });
    await _fetch_Mark_Dates();
    await _fetch_DonutChart_Day();
    await _fetch_DonutChart_Month();
    await _fetch_DonutChart_Year();
    await _fetch_BarChart_Day();
    await _fetch_BarChart_Month();
    await _fetch_BarChart_Year();
    await _fetch_Status_Day();
    await _fetch_Status_Month();
    await _fetch_Status_Year();
  }


  Future<void> _fetchcalendarDay(String date) async {
    print("Fetching data for date: $date");
    DateTime startDate = DateTime.parse(date);
    print('startDate');
    print(startDate);
    print('date *********************');
    print(date);

    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
      '''
    SELECT *
      FROM Transactions
      JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
      WHERE DATE(Transactions.date_user) = '${startDate.year}-${startDate.month.toString().padLeft(2,'0')}-${startDate.day.toString().padLeft(2,'0')}'
      ''',
    );
    print("__________________");
    print('${startDate.year}-${startDate.month}-${startDate.day}' );
    print("__________________");
    print("________result__________");
    print(result);
    setState(() {
      selectedDateExpenses = result.map((data) {
        return {
          'type': data['type_transaction'] ?? '-',
          'amount': data['amount_transaction'] ?? 0.0,
          'memo': data['memo_transaction'] ?? '-',
          'ID':data['ID_type_transaction'] ?? '-',
          'incomeexpense':data['type_expense'] ?? '-',
          'ID_transaction_Primary':data['ID_transaction']?? '-',
        };
      }).toList();
    });
  }

  Future<void> _fetch_DonutChart_Day() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction,
           SUM(Transactions.amount_transaction) AS total_amount_Pie,
           Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE Transactions.type_expense = 1
    AND DATE(Transactions.date_user) = DATE("now","localtime")  
    GROUP BY Transactions.ID_type_transaction
    '''
    );
    // double total = 0.0;
    // for(var r in result){
    //   total += r['total_amount_Pie'] as double;
    // }
    //print(total);
    print(result.isEmpty);
    print('Result from database day(donut): $result'); // ตรวจสอบผลลัพธ์ที่ได้
    setState(() {
      pieChartSections = result.map((data) {
        final color = typeToColor[data['type_transaction']] ?? Colors.grey;
       // final percentage = (data['total_amount_Pie'].toDouble()/ total * 100).toStringAsFixed(1);
        return PieChartSectionData(
          value: data['total_amount_Pie'].toDouble(),
          title: data['type_transaction'],//+' ${percentage}%',
          color: color,
          radius: 50,
          showTitle: false,
        );
      }).toList();
    });
  }

  Future<void> _fetch_DonutChart_Month() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
      SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_amount_Pie, Type_transaction.type_transaction
      FROM Transactions
      JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
      WHERE Transactions.type_expense = 1
      AND strftime('%Y-%m', Transactions.date_user) = strftime('%Y-%m', 'now',"localtime")
      GROUP BY Transactions.ID_type_transaction
    ''');
    print('Result from database month: $result');
    setState(() {
      pieChartSections = result.map((data) {
        final color = typeToColor[data['type_transaction']] ?? Colors.grey;
        return PieChartSectionData(
          value: data['total_amount_Pie'].toDouble(),
          title: data['type_transaction'],
          color: color,
          radius: 50,
          showTitle: false,
        );
      }).toList();
    });
  }

  Future<void> _fetch_DonutChart_Year() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
      SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_amount_Pie, Type_transaction.type_transaction
      FROM Transactions
      JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
      WHERE Transactions.type_expense = 1
      AND strftime('%Y', Transactions.date_user) = strftime('%Y', 'now','localtime')
      GROUP BY Transactions.ID_type_transaction
    ''');
    print('Result from year  : $result');
    setState(() {
      pieChartSections = result.map((data) {
        final color = typeToColor[data['type_transaction']] ?? Colors.grey;
        return PieChartSectionData(
          value: data['total_amount_Pie'].toDouble(),
          title: data['type_transaction'],
          color: color,
          radius: 50,
          showTitle: false,
        );
      }).toList();
    });
  }

  Future<void> _fetch_Status_Day() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_amount,
           Transactions.type_expense, Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE DATE(Transactions.date_user) = DATE("now", "localtime")
    GROUP BY Transactions.ID_type_transaction, Transactions.type_expense
    '''
    );
    print('Status for today: $result');
    setState(() {
      statusExpenses = result.map((data) {
        return {
          'type': data['type_transaction'],
          'amount': data['total_amount'] ?? 0.0,  // ตั้งค่าเริ่มต้นเป็น 0.0 ถ้าเป็น null
          'isExpense': data['type_expense'] == 1,
        };
      }).toList();
    });
  }

  Future<void> _fetch_Status_Month() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_amount,
           Transactions.type_expense, Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE strftime('%Y-%m', Transactions.date_user) = strftime('%Y-%m', 'now','localtime')  
    GROUP BY Transactions.ID_type_transaction, Transactions.type_expense
    '''
    );
    // ตรวจสอบผลลัพธ์ที่ได้จากฐานข้อมูล
    print('Status for this month: $result');

    // กำหนดค่าแสดงผล หรือ อัพเดท state ที่ต้องการแสดงบน UI
    setState(() {
      statusExpenses = result.map((data) {
        return {
          'type': data['type_transaction'],
          'amount': data['total_amount'] ?? 0.0, // ตั้งค่าเริ่มต้นเป็น 0.0 ถ้าเป็น null
          'isExpense': data['type_expense'] == 1, // ระบุว่าเป็นรายจ่ายหรือรายรับ
        };
      }).toList();
    });
  }

  Future<void> _fetch_Status_Year() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_amount,
           Transactions.type_expense, Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE strftime('%Y', Transactions.date_user) = strftime('%Y', 'now','localtime') 
    GROUP BY Transactions.ID_type_transaction, Transactions.type_expense
    '''
    );
    // ตรวจสอบผลลัพธ์ที่ได้จากฐานข้อมูล
    print('Status for this year: $result');

    // อัพเดทข้อมูลใน UI
    setState(() {
      statusExpenses = result.map((data) {
        return {
          'type': data['type_transaction'],
          'amount': data['total_amount'] ?? 0.0, // ตั้งค่าเริ่มต้นเป็น 0.0 ถ้าเป็น null
          'isExpense': data['type_expense'] == 1, // ระบุว่าเป็นรายจ่ายหรือรายรับ
        };
      }).toList();
    });
  }

  Future<void> _fetch_BarChart_Day() async {
    final List<Map<String, dynamic>> incomeResult = await DatabaseManagement.instance.rawQuery(
      'SELECT SUM(amount_transaction) AS total_income FROM transactions WHERE type_expense = 0 AND DATE(date_user) = DATE("now","localtime")',
    );

    final List<Map<String, dynamic>> expenseResult = await DatabaseManagement.instance.rawQuery(
      'SELECT SUM(amount_transaction) AS total_expense FROM transactions WHERE type_expense = 1 AND DATE(date_user) = DATE("now","localtime")',
    );

    setState(() {
      totalIncome = incomeResult.isNotEmpty && incomeResult[0]['total_income'] != null
          ? incomeResult[0]['total_income'].toDouble()
          : 0.0;
      totalExpense = expenseResult.isNotEmpty && expenseResult[0]['total_expense'] != null
          ? expenseResult[0]['total_expense'].toDouble()
          : 0.0;
    });
  }

  Future<void> _fetch_BarChart_Month() async {
    final List<Map<String, dynamic>> incomeResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_income FROM transactions WHERE type_expense = 0 AND strftime("%m", date_user) = strftime("%m", "now") AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'
    );

    final List<Map<String, dynamic>> expenseResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_expense FROM transactions WHERE type_expense = 1 AND strftime("%m", date_user) = strftime("%m", "now") AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'
    );

    setState(() {
      totalIncome = incomeResult.isNotEmpty && incomeResult[0]['total_income'] != null
          ? incomeResult[0]['total_income'].toDouble()
          : 0.0;
      totalExpense = expenseResult.isNotEmpty && expenseResult[0]['total_expense'] != null
          ? expenseResult[0]['total_expense'].toDouble()
          : 0.0;
    });
  }

  Future<void> _fetch_BarChart_Year() async {
    final List<Map<String, dynamic>> incomeResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_income '
            'FROM transactions '
            'WHERE type_expense = 0 '
            'AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'  // เงื่อนไขสำหรับดึงข้อมูลเฉพาะปีปัจจุบัน
    );

    final List<Map<String, dynamic>> expenseResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_expense '
            'FROM transactions '
            'WHERE type_expense = 1 '
            'AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'  // เงื่อนไขสำหรับดึงข้อมูลเฉพาะปีปัจจุบัน
    );

    setState(() {
      totalIncome = incomeResult.isNotEmpty && incomeResult[0]['total_income'] != null
          ? incomeResult[0]['total_income'].toDouble()
          : 0.0;
      totalExpense = expenseResult.isNotEmpty && expenseResult[0]['total_expense'] != null
          ? expenseResult[0]['total_expense'].toDouble()
          : 0.0;
    });
  }


  void _show_DonutChart(BuildContext context) {
    setState(() {
      if (selectedButton == 'Day') {
        _fetch_DonutChart_Day();
      } else if (selectedButton == 'Month') {
        _fetch_DonutChart_Month();
      } else if (selectedButton == 'Year') {
        _fetch_DonutChart_Year();
      }
    });
  }

  // ฟังก์ชันแสดง Status Expense
  void _show_Status_Expense(BuildContext context) {
    setState(() {
    if (selectedButton == 'Day') {
      _fetch_Status_Day(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Day
    } else if (selectedButton == 'Month') {
      _fetch_Status_Month(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Month
    } else if (selectedButton == 'Year') {
      _fetch_Status_Year(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Year
    }
    });
  }

  // ฟังก์ชันแสดง Bar Chart และดึงข้อมูล
  void _show_BarChart(BuildContext context) {
    if (selectedButton == 'Day') {
      _fetch_BarChart_Day();
    } else if (selectedButton == 'Month') {
      _fetch_BarChart_Month() ;
    } else if (selectedButton == 'Year') {
      _fetch_BarChart_Year();
    }
  }

}