const officerAssignmentStrain = 20;
const officerIdleRecovery = 10;
const officerBusyRecovery = 5;

int officerFatiguePenalty(int strain) => 4 * (strain ~/ 10);
