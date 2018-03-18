public with sharing class SFDCAccessController {

	/////////////////////////////
	//// Describe
	//// Get Describe methods
	/////////////////////////////

	public static Map<String,Schema.SObjectType> getGlobalDescribe() {
		return Schema.getGlobalDescribe();
	}
	public static Schema.DescribeSObjectResult getDescribe(Schema.SObjectType S) {
		return S.getDescribe();
	}
	public static Schema.SObjectType getSObjectType(String RecordIdStr) {
		Schema.SObjectType result = NULL;
		try {
			Id RecordId = Id.valueOf(RecordIdStr);
			result = RecordId.getSObjectType();
		}
		catch (Exception e) {
			result = NULL;
		}
		return result;
	}

	/////////////////////////////
	//// DML methods
	/////////////////////////////

	private static final Boolean isGuestUser = (UserInfo.getUserType() == 'Guest');
	private static final Boolean isPortalLoginedUser = (!isGuestUser && (UserInfo.getUserType()=='Standard' ? false : true));

	// Check fields access
	public static Set<Schema.DescribeFieldResult> GetNotAccessibleFields(Schema.DescribeFieldResult[] fields) {
		Set<Schema.DescribeFieldResult> result = new Set<Schema.DescribeFieldResult>();
		for (Schema.DescribeFieldResult field : fields) {
			if (!field.isAccessible()) {
				result.add(field);
			}
		}
		return result;
	}

	//Accessible
	public static Boolean AccessibleWithoutSharing(String obj, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notAccessibleFLS = acws.hasNotAccessibleFLS(fields);
		if (notAccessibleFLS != NULL) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_ACCESS,
				obj,
				notAccessibleFLS
			);
		}
		return true;
	}
	//Createable
	public static Boolean CreateableWithoutSharing(String obj, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notCreateableFLS = acws.hasNotCreateableFLS(fields);
		if (notCreateableFLS != NULL) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_ACCESS,
				obj,
				notCreateableFLS
			);
		}
		return true;
	}

	// Insert
	public static Database.SaveResult InsertWithoutSharing(sObject obj, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notCreateableFLS = acws.hasNotCreateableFLS(fields);
		Boolean isObjectCreateable = acws.isObjectCreateable(obj);
		if (notCreateableFLS != NULL || !isObjectCreateable) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_CREATE,
				obj.getSObjectType().getDescribe().getName(),
				notCreateableFLS
			);
		}
		return Database.insert(obj);
	}
	public static Database.SaveResult[] InsertWithoutSharing(sObject[] objs, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notCreateableFLS = acws.hasNotCreateableFLS(fields);
		Boolean isObjectsCreateable = acws.isObjectCreateable(objs[0]);
		if (notCreateableFLS != NULL || !isObjectsCreateable) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_CREATE,
				objs.getSObjectType().getDescribe().getName(),
				notCreateableFLS
			);
		}
		return Database.insert(objs);
	}

	// Update
	public static Database.SaveResult UpdateWithoutSharing(sObject obj, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notUpdateableFLS = (isGuestUser && !obj.getSObjectType().getDescribe().isCustom()) ? acws.hasNotCreateableFLS(fields) : acws.hasNotUpdateableFLS(fields);
		Boolean isObjectUpdateable = acws.isObjectUpdateable(obj);
		if (notUpdateableFLS != NULL || !isObjectUpdateable) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_UPDATE,
				obj.getSObjectType().getDescribe().getName(),
				notUpdateableFLS
			);
		}
		return Database.update(obj);
	}
	public static Database.SaveResult[] UpdateWithoutSharing(sObject[] objs, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notUpdateableFLS = (isGuestUser && !objs.getSObjectType().getDescribe().isCustom()) ? acws.hasNotCreateableFLS(fields) : acws.hasNotUpdateableFLS(fields);
		Boolean isObjectsUpdateable = acws.isObjectUpdateable(objs[0]);
		if (notUpdateableFLS != NULL || !isObjectsUpdateable) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_UPDATE,
				objs.getSObjectType().getDescribe().getName(),
				notUpdateableFLS
			);
		}
		return Database.update(objs);
	}

	// Upsert
	public static Database.UpsertResult UpsertWithoutSharing(sObject obj, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notCreateableFLS = acws.hasNotCreateableFLS(fields);
		String notUpdateableFLS = (isGuestUser && !obj.getSObjectType().getDescribe().isCustom()) ? notCreateableFLS : acws.hasNotUpdateableFLS(fields);
		Boolean isObjectUpserteable = acws.isObjectUpserteable(obj);
		if (notCreateableFLS != NULL || notUpdateableFLS != NULL || !isObjectUpserteable) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				(notCreateableFLS!=NULL) ? SFDCAccessControlException.ExceptionReason.NO_CREATE : SFDCAccessControlException.ExceptionReason.NO_UPDATE,
				obj.getSObjectType().getDescribe().getName(),
				(notCreateableFLS!=NULL) ? notCreateableFLS : notUpdateableFLS
			);
		}
		return Database.upsert(obj);
	}
	public static Database.UpsertResult[] UpsertWithoutSharing(sObject[] objs, String err, Schema.DescribeFieldResult[] fields) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		String notCreateableFLS = acws.hasNotCreateableFLS(fields);
		String notUpdateableFLS = (isGuestUser && !objs.getSObjectType().getDescribe().isCustom()) ? notCreateableFLS : acws.hasNotUpdateableFLS(fields);
		Boolean isObjectsUpserteable = acws.isObjectUpserteable(objs[0]);
		if (notCreateableFLS != NULL || notUpdateableFLS != NULL || !isObjectsUpserteable) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
				(notCreateableFLS!=NULL) ? SFDCAccessControlException.ExceptionReason.NO_CREATE : SFDCAccessControlException.ExceptionReason.NO_UPDATE,
				objs.getSObjectType().getDescribe().getName(),
				(notCreateableFLS!=NULL) ? notCreateableFLS : notUpdateableFLS
			);
		}
		return Database.upsert(objs);
	}

	// Delete
	public static Database.DeleteResult DeleteWithoutSharing(sObject obj, String err) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		Boolean isObjectDeletable = (isGuestUser && !obj.getSObjectType().getDescribe().isCustom()) ? acws.isObjectCreateable(obj) : acws.isObjectDeletable(obj);
		if (isObjectDeletable == false) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_DELETE,
				obj.getSObjectType().getDescribe().getName(),
				NULL
			);
		}
		return Database.delete(obj);
	}
	public static Database.DeleteResult[] DeleteWithoutSharing(sObject[] objs, String err) {
		FLSAccessControllerWithSharing acws = new FLSAccessControllerWithSharing();
		Boolean isObjectsDeletable = (isGuestUser && !objs.getSObjectType().getDescribe().isCustom()) ? acws.isObjectCreateable(objs[0]) : acws.isObjectDeletable(objs[0]);
		if (isObjectsDeletable == false) {
			throw new SFDCAccessControlException(
				'AccessViolationException',
				SFDCAccessControlException.ExceptionType.OBJECT_ACCESS_VIOLATION,
				SFDCAccessControlException.ExceptionReason.NO_DELETE,
				objs.getSObjectType().getDescribe().getName(),
				NULL
			);
		}
		return Database.delete(objs);
	}

	private with sharing class FLSAccessControllerWithSharing {
		public String hasNotAccessibleFLS(Schema.DescribeFieldResult[] fields) {
			String result = NULL;
			for (Schema.DescribeFieldResult field : fields) {
				Boolean isAccessible = field.isAccessible();
				if (!isAccessible) {
					result = field.getName();
					break;
				}
			}
			return result;
		}
		public String hasNotCreateableFLS(Schema.DescribeFieldResult[] fields) {
			String result = NULL;
			for (Schema.DescribeFieldResult field : fields) {
				Boolean isCreateable = field.isCreateable();
				if (!isCreateable) {
					result = field.getName();
					break;
				}
			}
			return result;
		}
		public String hasNotUpdateableFLS(Schema.DescribeFieldResult[] fields) {
			String result = NULL;
			for (Schema.DescribeFieldResult field : fields) {
				// For Master-Detail fields check for Creatable instead of Updateable access
				Boolean isUpdateable = (field.getRelationshipOrder() != NULL) ? field.isCreateable() : field.isUpdateable();
				if (!isUpdateable) {
					result = field.getName();
					break;
				}
			}
			return result;
		}
		public Boolean isObjectAccessible(sObject obj) {
			return obj.getSObjectType().getDescribe().isAccessible();
		}
		public Boolean isObjectCreateable(sObject obj) {
			return obj.getSObjectType().getDescribe().isCreateable();
		}
		public Boolean isObjectUpserteable(sObject obj) {
			return (obj.getSObjectType().getDescribe().isCreateable() && obj.getSObjectType().getDescribe().isUpdateable());
		}
		public Boolean isObjectUpdateable(sObject obj) {
			return obj.getSObjectType().getDescribe().isUpdateable();
		}
		public Boolean isObjectDeletable(sObject obj) {
			return obj.getSObjectType().getDescribe().isDeletable();
		}
	}

}