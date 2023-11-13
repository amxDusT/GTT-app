// ignore_for_file: constant_identifier_names

enum EdisuCardType {
  EF_PARAM(0x17, lid: 0x3100, lidFile: 0x3102),
  EF_CONTRACTS(0x18, lid: 0x3100, lidFile: 0x3120, numRec: 8);

  static const String DF1Hex = "315449432E494341D38012009301";
  final int sfi;
  static const int recSize = 29;
  final int numRec;
  final int? lid, lidFile;
  const EdisuCardType(this.sfi, {this.lid, this.lidFile, this.numRec = 1});
}
