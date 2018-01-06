DROP TABLE IF EXISTS gc_fields_day_metric;

CREATE TABLE gc_fields_day_metric (field TEXT, activityType TEXT, fieldDisplayName TEXT, uom TEXT );

INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumDistanceLightlyActive', 'day', 'Lightly Active', 'kilometer');
INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumDistanceModeratelyActive', 'day', 'Moderately Active', 'kilometer');
INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumDistanceVeryActive', 'day', 'Very Active', 'kilometer');

INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumDurationLightlyActive', 'day', 'Lightly Active', 'minute');
INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumDurationModeratelyActive', 'day', 'Moderately Active', 'minute');
INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumDurationVeryActive', 'day', 'Very Active', 'minute');

INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumStep', 'day', 'Steps', 'step');
INSERT INTO gc_fields_day_metric (field,activityType,fieldDisplayName,uom) VALUES ('SumFloorClimbed', 'day', 'Floor Climbed', 'dimensionless');
