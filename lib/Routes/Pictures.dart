import 'package:flutter/material.dart';

class Pictures extends StatefulWidget {

    @override
    State<StatefulWidget> createState() => _Pictures();
}

class _Pictures extends State<Pictures> {
    @override
    void initState() {
        super.initState();

    }

    @override
    Widget build(BuildContext context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: MediaQuery.of(context).viewPadding.top),
              const Center(
                child: Text("")
              )
            ],
          )
        );
    }
}