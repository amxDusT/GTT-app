// ignore_for_file: constant_identifier_names

enum CardFileType {
  EF_ENVIRONMENT(
    0x07,
    lid: 0x2000,
    lidFile: 0x2001,
    numRec: 2, // 2,
  ),
  /*EF_ID(
    0x03,
    lid: 0x3f00,
    lidFile: 0x0003,
  ),*/
  EF_EVENTS_LOG(
    0x08,
    lid: 0x2000,
    lidFile: 0x2010,
    numRec: 3,
  ),
  EF_CONTRACT_LIST(
    0x1E,
    lid: 0x2000,
    lidFile: 0x2050,
  ),
  EF_CONTRACTS(
    0x09,
    lid: 0x2000,
    lidFile: 0x2020,
    numRec: 8,
  ),
  EF_SPECIAL_EVENTS(
    0x1D,
    lid: 0x2000,
    lidFile: 0x2040,
    numRec: 8, //8,
  ),
  TICKET_COUNTERS(
    0x19,
    lid: 0x2000,
    lidFile: 0x2069,
  );

  /*
  TICKET_SUPPL_COUNTERS(
    0x13,
    lid: 0x2000,
    lidFile: 0x206A,
  ),
  TICKET_FREE_FILE(
    0x01,
    lid: 0x2000,
    lidFile: 0x20F0,
    numRec: 4
  ),

  EF_MISC(0x1B, lid: 0x3100, lidFile: 0x3150, numRec: 8);
  */
  static const String DF1Hex = "315449432E494341D38012009101";
  final int sfi;
  static const int recSize = 29;
  final int numRec;
  final int? lid, lidFile;
  const CardFileType(this.sfi, {this.lid, this.lidFile, this.numRec = 1});

  int get sfiApdu => (sfi << 3) + 0x04;
}
