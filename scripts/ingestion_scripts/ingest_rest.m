%% This script adds a few more things that have to added to the database



%% add notification_settings
% for definitions, see lab.NotificationSettings

notification.notification_settings_date = '2017-01-01';
notification.max_response_time = 30;
notification.change_cutoff_time = [5,0];
notification.weekly_digest_day = 'Mon';
notification.weekly_digest_time = [5,0];

inserti(lab.NotificationSettings, notification)

%% add duty roaster
% for definitions, see lab.DutyRoaster

duty.duty_roaster_date = '2017-01-01';
duty.monday_duty    = 'sbaptista';
duty.tuesday_duty   = 'sbaptista';
duty.wednesday_duty = 'sstein';
duty.thursday_duty  = 'sstein';
duty.friday_duty    = 'sstein';
duty.saturday_duty  = 'sbaptista';
duty.sunday_duty    = 'sbaptista';

inserti(lab.DutyRoaster, duty)


%% add duty roaster
% for definitions, see lab.UserSecondaryContact

sc.user_id = 'sakoay';
sc.secondary_contact = 'lucas';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'lucas';
sc.secondary_contact = 'sakoay';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'edward';
sc.secondary_contact = 'sakoay';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'ben';
sc.secondary_contact = 'joel';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'joel';
sc.secondary_contact = 'ben';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'sbolkan';
sc.secondary_contact = 'joel';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'mioffe';
sc.secondary_contact = 'lucas';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'testuser';
sc.secondary_contact = 'testuser';
inserti(lab.UserSecondaryContact, sc)

sc.user_id = 'zhihao';
sc.secondary_contact = 'mioffe';
inserti(lab.UserSecondaryContact, sc)
