const seasonNames = ['Xuân', 'Hạ', 'Thu', 'Đông'];
const seasonalActions = 12;
const securityCooldown = 3;

String seasonDate(int turn) =>
    'mùa ${seasonNames[(turn - 1) % 4]} · năm ${(turn - 1) ~/ 4 + 1}';

String elapsedTime(int turns, {bool seasonal = false}) =>
    seasonal
        ? '${turns ~/ 4} năm ${turns % 4} mùa'
        : '${turns ~/ 52} năm ${turns % 52} tuần';
