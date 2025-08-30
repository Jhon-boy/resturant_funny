//Modelo para almacenar la información del dispositivo
class DeviceInfoModel {
  final String? modelo;
  final String? fabricante;
  final String? sistemaOperativo;
  final String? versionSO;
  final String? idUnico;
  final String? ip;
  final String? wifiSSID;
  final String? wifiBSSID;

  DeviceInfoModel({
    this.modelo,
    this.fabricante,
    this.sistemaOperativo,
    this.versionSO,
    this.idUnico,
    this.ip,
    this.wifiSSID,
    this.wifiBSSID,
  });

  Map<String, dynamic> toJson() {
    return {
      "modelo": modelo,
      "fabricante": fabricante,
      "sistemaOperativo": sistemaOperativo,
      "versionSO": versionSO,
      "idUnico": idUnico,
      "ip": ip,
      "wifiSSID": wifiSSID,
      "wifiBSSID": wifiBSSID,
    };
  }
}
