// Future<void> init() async {
//   try {
//     //사용자 단말의 플랫폼 버전을 획득
//     String? platformVersion = await TmapUiSdk().getPlatformVersion();

//     //사용자 인증 입력
//     AuthData authData = AuthData(
//         clientApiKey: "", // 필수
//         userKey: "",
//         clientServiceName: "",
//         clientID: "",
//         clientDeviceId: "",
//         clientAppVersion: "",
//         clientApCode: "");

//     //사용자 인증, 초기화
//     InitResult? result = await TmapUISDKManager().initSDK(authData);

//     if (platformVersion != null &&
//         result != null &&
//         result == InitResult.granted) {
//       log("초기화 성공 : $platformVersion / $result");
//     } else {
//       log("초기화 실패 : $platformVersion / $result");
//     }
//   } catch (e) {
//     log("error ${e.toString()}");
//   }
// }
