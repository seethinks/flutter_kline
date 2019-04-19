/*
 * @Description: 
 * @Author: zhaojijin
 * @LastEditors: Please set LastEditors
 * @Date: 2019-04-16 17:31:59
 * @LastEditTime: 2019-04-18 16:47:29
 */
import 'package:flutter/material.dart';
import 'package:flutter_kline/packages/bloc/klineBloc.dart';
import 'package:flutter_kline/packages/bloc/klineBlocProvider.dart';
import 'package:flutter_kline/packages/model/klineModel.dart';
import 'package:flutter_kline/packages/model/klineConstrants.dart';

class KlinePriceGridWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    KlineBloc klineBloc = KlineBlocProvider.of<KlineBloc>(context);

    return StreamBuilder(
      stream: klineBloc.currentKlineListStream,
      builder: (BuildContext context, AsyncSnapshot<List<Market>> snapshot) {
        List<Market> currentScreenList =
            snapshot.data ?? [Market(0, 0, 0, 0, 0)];
        return CustomPaint(
          size: Size.infinite,
          painter: _KlineGridPainter(
              currentScreenList, klineBloc.priceMax, klineBloc.priceMin),
        );
      },
    );
  }
}

class _KlineGridPainter extends CustomPainter {
  final List<Market> dataList;
  final double max;
  final double min;

  _KlineGridPainter(this.dataList, this.max, this.min);

  final double lineWidth = kGridLineWidth;
  final Color lineColor = kGridLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (max == null || min == null) {
      return;
    }
    double height = size.height - kTopMargin;
    double width = size.width;
    Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    //绘制横线/价格
    double heightOffset = height / kGridRowCount;
    double priceOffset = (max - min) / kGridRowCount;
    double priceOriginX =
        width - max.toStringAsPrecision(kGridPricePrecision).length * 6;
    // 字体是10号字，但是实际上字体的高度会大于10所以加3
    double textHeight = kGridPriceFontSize + 3;
    print('maxPrice: $max, minPrice: $min'); // 5407.18
    for (var i = 0; i < kGridRowCount + 1; i++) {
      canvas.drawLine(Offset(0, kTopMargin + heightOffset * i),
          Offset(width, kTopMargin + heightOffset * i), linePaint);
      _drawText(
          canvas,
          Offset(priceOriginX, kTopMargin + heightOffset * i - textHeight),
          (min + priceOffset * (kGridRowCount - i))
              .toStringAsPrecision(kGridPricePrecision));
    }
    // 画竖线
    double widthOffset = (width ~/ kGridColumCount).toDouble();
    for (int i = 1; i < kGridColumCount; i++) {
      canvas.drawLine(Offset(i * widthOffset, 0),
          Offset(i * widthOffset, height + kTopMargin), linePaint);
    }
  }

  _drawText(Canvas canvas, Offset offset, String text) {
    TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: lineColor,
            fontSize: kGridPriceFontSize,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}