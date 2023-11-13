import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_gtt/models/smart_card/card_files.dart';
import 'package:nfc_manager/platform_tags.dart';

class ApduUtils {
  static Uint8List getReadRecordSfiCommand(int sfi, int recordId) {
    List<int> read = [
      0x00,
      0xB2,
      recordId,
      (sfi << 3) + 0x04,
      CardFileType.recSize
    ];
    return Uint8List.fromList(read);
  }

  static Future<Uint8List> readRecordId(
      IsoDep tag, dynamic cardFileType, int recordId) async {
    if(recordId <= 0){
      throw 'record ID not valid';
    }
    else if (cardFileType.numRec < recordId) {
      throw 'This file does not have that record ID';
    }
    Uint8List cmdResult = await tag.transceive(
      data: getReadRecordSfiCommand(cardFileType.sfi, recordId),
    );

    return _cleanResult(cmdResult);
  }

  static Future<List<Uint8List>> getReadRecordFile(
      IsoDep tag, dynamic cardFileType) async {
    List<Uint8List> list = [];
    for (int i = 0; i < cardFileType.numRec; i++) {
      list.add(await readRecordId(tag, cardFileType, i + 1));
    }
    return list;
  }

  static Uint8List getSelectAIDCommand(Uint8List aid) {
    List<int> read = [0x00, 0xA4, 0x04, 0x00, aid.lengthInBytes];
    read.addAll(aid);

    return Uint8List.fromList(read);
  }

  static Uint8List _cleanResult(Uint8List result) {
    if (result[result.length - 2] != 0x90) {
      throw 'Could not retrieve the requested data ${hex.encode(result.sublist(result.length - 2))}';
    }
    return result.sublist(0, result.length - 2);
  }
}
