insert new PermissionSetAssignment(
    AssigneeId = [SELECT Id FROM User WHERE alias = 'autoproc'].Id,
    PermissionSetId = '0PS8G0000000DsoWAE'
);