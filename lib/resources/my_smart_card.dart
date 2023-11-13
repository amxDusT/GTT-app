import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_gtt/resources/utils/gtt_date.dart';

class MySmartCard {
  static List<Uint8List> getData() {
    //list.add(Uint8List.fromList([0x6F,0x28,0x84,0x0E,0x31,0x54,0x49,0x43,0x2E,0x49,0x43,0x41,0xD3,0x80,0x12,0x00,0x91,0x01,0xA5,0x16,0xBF,0x0C,0x13,0xC7,0x08,0x00,0x00,0x00,0x00,0x38,0x1C,0x76,0xC5,0x53,0x07,0x06,0x3C,0x23,0xC0,0x10,0x10,0x01,0x90,0x00]));
    final List<Uint8List> list = [];
    //0 - checks if smartcard good (?)
    /*
      [3-17] = 0E315449432E494341D38012009101 = type of data requestested from card : 1TIC.ICA
      [29-33] = 381C76C5 = card number
      7 byte dopo '53' = Startup information (holds Application subtype)
        => 07063C23C01010 = Cx = tipo di carta:
              C0 = BIP
              C1 = PYOU
              C2 = EDISU
              C3 = NFC
              C4 = TRENITALIA
              C5 = CB


      6F fci template {
        84 df name{
          315449432E494341D38012009101
        }
        A5 File Control Information (FCI) Proprietary Template{
          BF0C File Control Information (FCI) Issuer Discretionary Data{
            13C7 card Number? ??{
              00000000381C76C5
            }
            5307 app subtype???  {
              3C23C0101001
            }
          }
        }

      }
    */
    list.add(Uint8List.fromList(hex.decode(
        "6F28840E315449432E494341D38012009101A516BF0C13C70800000000381C76C55307063C23C01010019000")));
    //1 - smartcard type [28]--->                                                                   C0=BIP,C1=PYOU,C2=EDISU
    // creationDate [9][10][11]                               9:10:11 __ 6E6607
    Uint8List dateAsByte = GttDate.fromDateToByte(DateTime.now());
    print(dateAsByte);
    list.add(Uint8List.fromList(hex.decode(
        "0501030DEFFB2000026E66074B4C564B564E39394331385A31303048C09000")));
    //2 // contracts information
    list.add(Uint8List.fromList(hex.decode(
        "0501A10001A100014040000000000000000000000000000000000000009000")));
    //3
    list.add(Uint8List.fromList(hex.decode(
        "0105000002D10A472E7192FB698DDCFFAE110B71000AD2A0009B24267B9000")));
    //4
    list.add(Uint8List.fromList(hex.decode(
        "0105000002D10F619F698DDB61831CFFAE10A700005E94A000087B25369000")));
    //5
    list.add(Uint8List.fromList(hex.decode(
        "0105000002CB00000071AF1B69C61CFFAE10A8240078CBA0002E805FDF9000")));
    //6
    list.add(Uint8List.fromList(hex.decode(
        "00000000000000000000000000000000000000000000000000000000009000")));
    // 7
    list.add(Uint8List.fromList(hex.decode(
        "00000000000000000000000000000000000000000000000000000000009000")));
    // 8
    list.add(Uint8List.fromList(hex.decode(
        "00000000000000000000000000000000000000000000000000000000009000")));
    //9
    list.add(Uint8List.fromList(hex.decode(
        "00000000000000000000000000000000000000000000000000000000009000")));
    // 10
    list.add(Uint8List.fromList(hex.decode(
        "00000000000000000000000000000000000000000000000000000000009000")));
    //11
    list.add(Uint8List.fromList(hex.decode(
        "05010F619F2197247200000B00032100000000009724720000200043909000")));
    // 12
    list.add(Uint8List.fromList(hex.decode(
        "05010F619F219723F500000D00032100000000009723F5000020001A6A9000")));
    // 13
    list.add(Uint8List.fromList(hex.decode(
        "05010F619F21971F4600000F0003210000000000971F4600002000620C9000")));
    // 14
    list.add(Uint8List.fromList(hex.decode(
        "07FB2A07E59B07EA8407DE1A00000000000000000000000000000000009000")));
    return list;
  }

  static List<Uint8List> getTicketData() {
    final List<Uint8List> ticket1 = [];
    //0
    ticket1.add(Uint8List.fromList(hex.decode("057D6292")));
    //1
    ticket1.add(Uint8List.fromList(hex.decode("AD2954E9")));
    //2
    ticket1.add(Uint8List.fromList(hex.decode("3915F203")));
    //3
    ticket1.add(Uint8List.fromList(hex.decode("07FFEFFF")));
    //4
    ticket1.add(Uint8List.fromList(hex.decode("01040000")));
    //5
    ticket1.add(Uint8List.fromList(hex.decode("0101012F")));
    //6
    ticket1.add(Uint8List.fromList(hex.decode("68970000")));
    //7
    ticket1.add(Uint8List.fromList(hex.decode("00AE10A7")));
    // 8
    ticket1.add(Uint8List.fromList(hex.decode("0200645C")));
    // 9
    ticket1.add(Uint8List.fromList(hex.decode("397D91B4")));
    // 10 : validation date
    Uint8List dateAsByte = GttDate.fromDateToByte(DateTime.now());
    ticket1.add(Uint8List.fromList(
        hex.decode("${hex.encode(dateAsByte).toUpperCase()}00")));
    ticket1.add(Uint8List.fromList(hex.decode("04F80000")));
    ticket1.add(Uint8List.fromList(hex.decode("68A4F900")));
    ticket1.add(Uint8List.fromList(hex.decode("00050004")));
    ticket1.add(Uint8List.fromList(hex.decode("F8AE1079")));
    ticket1.add(Uint8List.fromList(hex.decode("9E1291E4")));
    return ticket1;
  }
}
