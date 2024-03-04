import 'package:blank_tool/models/exploers_data.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  List<FileInfoModel> data = <FileInfoModel>[
    FileInfoModel(name: "A1"),
    FileInfoModel(name: "A2"),
    FileInfoModel(name: "A3"),
  ];

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: DataTable(
        dividerThickness: 0.1,
        columns: [
          const DataColumn(label: Text('名称')),
          const DataColumn(label: Text('大小')),
        ],
        rows: widget.data
            .map((e) => DataRow(
                  cells: [
                    DataCell(
                      Text(e.name),
                    ),
                    DataCell(
                      Text("${e.size}"),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
