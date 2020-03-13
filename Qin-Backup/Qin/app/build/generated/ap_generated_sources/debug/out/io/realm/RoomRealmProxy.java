package io.realm;


import android.annotation.TargetApi;
import android.os.Build;
import android.util.JsonReader;
import android.util.JsonToken;
import io.realm.RealmObjectSchema;
import io.realm.RealmSchema;
import io.realm.exceptions.RealmMigrationNeededException;
import io.realm.internal.ColumnInfo;
import io.realm.internal.LinkView;
import io.realm.internal.RealmObjectProxy;
import io.realm.internal.Row;
import io.realm.internal.SharedRealm;
import io.realm.internal.Table;
import io.realm.internal.android.JsonUtils;
import io.realm.log.RealmLog;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class RoomRealmProxy extends edu.bfa.ss.qin.Util.Room
    implements RealmObjectProxy, RoomRealmProxyInterface {

    static final class RoomColumnInfo extends ColumnInfo
        implements Cloneable {

        public long IDIndex;
        public long NameIndex;
        public long LocationIndex;

        RoomColumnInfo(String path, Table table) {
            final Map<String, Long> indicesMap = new HashMap<String, Long>(3);
            this.IDIndex = getValidColumnIndex(path, table, "Room", "ID");
            indicesMap.put("ID", this.IDIndex);
            this.NameIndex = getValidColumnIndex(path, table, "Room", "Name");
            indicesMap.put("Name", this.NameIndex);
            this.LocationIndex = getValidColumnIndex(path, table, "Room", "Location");
            indicesMap.put("Location", this.LocationIndex);

            setIndicesMap(indicesMap);
        }

        @Override
        public final void copyColumnInfoFrom(ColumnInfo other) {
            final RoomColumnInfo otherInfo = (RoomColumnInfo) other;
            this.IDIndex = otherInfo.IDIndex;
            this.NameIndex = otherInfo.NameIndex;
            this.LocationIndex = otherInfo.LocationIndex;

            setIndicesMap(otherInfo.getIndicesMap());
        }

        @Override
        public final RoomColumnInfo clone() {
            return (RoomColumnInfo) super.clone();
        }

    }
    private RoomColumnInfo columnInfo;
    private ProxyState<edu.bfa.ss.qin.Util.Room> proxyState;
    private static final List<String> FIELD_NAMES;
    static {
        List<String> fieldNames = new ArrayList<String>();
        fieldNames.add("ID");
        fieldNames.add("Name");
        fieldNames.add("Location");
        FIELD_NAMES = Collections.unmodifiableList(fieldNames);
    }

    RoomRealmProxy() {
        proxyState.setConstructionFinished();
    }

    @Override
    public void realm$injectObjectContext() {
        if (this.proxyState != null) {
            return;
        }
        final BaseRealm.RealmObjectContext context = BaseRealm.objectContext.get();
        this.columnInfo = (RoomColumnInfo) context.getColumnInfo();
        this.proxyState = new ProxyState<edu.bfa.ss.qin.Util.Room>(this);
        proxyState.setRealm$realm(context.getRealm());
        proxyState.setRow$realm(context.getRow());
        proxyState.setAcceptDefaultValue$realm(context.getAcceptDefaultValue());
        proxyState.setExcludeFields$realm(context.getExcludeFields());
    }

    @Override
    @SuppressWarnings("cast")
    public int realmGet$ID() {
        proxyState.getRealm$realm().checkIfValid();
        return (int) proxyState.getRow$realm().getLong(columnInfo.IDIndex);
    }

    @Override
    public void realmSet$ID(int value) {
        if (proxyState.isUnderConstruction()) {
            // default value of the primary key is always ignored.
            return;
        }

        proxyState.getRealm$realm().checkIfValid();
        throw new io.realm.exceptions.RealmException("Primary key field 'ID' cannot be changed after object was created.");
    }

    @Override
    @SuppressWarnings("cast")
    public String realmGet$Name() {
        proxyState.getRealm$realm().checkIfValid();
        return (java.lang.String) proxyState.getRow$realm().getString(columnInfo.NameIndex);
    }

    @Override
    public void realmSet$Name(String value) {
        if (proxyState.isUnderConstruction()) {
            if (!proxyState.getAcceptDefaultValue$realm()) {
                return;
            }
            final Row row = proxyState.getRow$realm();
            if (value == null) {
                row.getTable().setNull(columnInfo.NameIndex, row.getIndex(), true);
                return;
            }
            row.getTable().setString(columnInfo.NameIndex, row.getIndex(), value, true);
            return;
        }

        proxyState.getRealm$realm().checkIfValid();
        if (value == null) {
            proxyState.getRow$realm().setNull(columnInfo.NameIndex);
            return;
        }
        proxyState.getRow$realm().setString(columnInfo.NameIndex, value);
    }

    @Override
    public edu.bfa.ss.qin.Util.Building realmGet$Location() {
        proxyState.getRealm$realm().checkIfValid();
        if (proxyState.getRow$realm().isNullLink(columnInfo.LocationIndex)) {
            return null;
        }
        return proxyState.getRealm$realm().get(edu.bfa.ss.qin.Util.Building.class, proxyState.getRow$realm().getLink(columnInfo.LocationIndex), false, Collections.<String>emptyList());
    }

    @Override
    public void realmSet$Location(edu.bfa.ss.qin.Util.Building value) {
        if (proxyState.isUnderConstruction()) {
            if (!proxyState.getAcceptDefaultValue$realm()) {
                return;
            }
            if (proxyState.getExcludeFields$realm().contains("Location")) {
                return;
            }
            if (value != null && !RealmObject.isManaged(value)) {
                value = ((Realm) proxyState.getRealm$realm()).copyToRealm(value);
            }
            final Row row = proxyState.getRow$realm();
            if (value == null) {
                // Table#nullifyLink() does not support default value. Just using Row.
                row.nullifyLink(columnInfo.LocationIndex);
                return;
            }
            if (!RealmObject.isValid(value)) {
                throw new IllegalArgumentException("'value' is not a valid managed object.");
            }
            if (((RealmObjectProxy) value).realmGet$proxyState().getRealm$realm() != proxyState.getRealm$realm()) {
                throw new IllegalArgumentException("'value' belongs to a different Realm.");
            }
            row.getTable().setLink(columnInfo.LocationIndex, row.getIndex(), ((RealmObjectProxy) value).realmGet$proxyState().getRow$realm().getIndex(), true);
            return;
        }

        proxyState.getRealm$realm().checkIfValid();
        if (value == null) {
            proxyState.getRow$realm().nullifyLink(columnInfo.LocationIndex);
            return;
        }
        if (!(RealmObject.isManaged(value) && RealmObject.isValid(value))) {
            throw new IllegalArgumentException("'value' is not a valid managed object.");
        }
        if (((RealmObjectProxy)value).realmGet$proxyState().getRealm$realm() != proxyState.getRealm$realm()) {
            throw new IllegalArgumentException("'value' belongs to a different Realm.");
        }
        proxyState.getRow$realm().setLink(columnInfo.LocationIndex, ((RealmObjectProxy)value).realmGet$proxyState().getRow$realm().getIndex());
    }

    public static RealmObjectSchema createRealmObjectSchema(RealmSchema realmSchema) {
        if (!realmSchema.contains("Room")) {
            RealmObjectSchema realmObjectSchema = realmSchema.create("Room");
            realmObjectSchema.add("ID", RealmFieldType.INTEGER, Property.PRIMARY_KEY, Property.INDEXED, Property.REQUIRED);
            realmObjectSchema.add("Name", RealmFieldType.STRING, !Property.PRIMARY_KEY, !Property.INDEXED, !Property.REQUIRED);
            if (!realmSchema.contains("Building")) {
                BuildingRealmProxy.createRealmObjectSchema(realmSchema);
            }
            realmObjectSchema.add("Location", RealmFieldType.OBJECT, realmSchema.get("Building"));
            return realmObjectSchema;
        }
        return realmSchema.get("Room");
    }

    public static RoomColumnInfo validateTable(SharedRealm sharedRealm, boolean allowExtraColumns) {
        if (!sharedRealm.hasTable("class_Room")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "The 'Room' class is missing from the schema for this Realm.");
        }
        Table table = sharedRealm.getTable("class_Room");
        final long columnCount = table.getColumnCount();
        if (columnCount != 3) {
            if (columnCount < 3) {
                throw new RealmMigrationNeededException(sharedRealm.getPath(), "Field count is less than expected - expected 3 but was " + columnCount);
            }
            if (allowExtraColumns) {
                RealmLog.debug("Field count is more than expected - expected 3 but was %1$d", columnCount);
            } else {
                throw new RealmMigrationNeededException(sharedRealm.getPath(), "Field count is more than expected - expected 3 but was " + columnCount);
            }
        }
        Map<String, RealmFieldType> columnTypes = new HashMap<String, RealmFieldType>();
        for (long i = 0; i < columnCount; i++) {
            columnTypes.put(table.getColumnName(i), table.getColumnType(i));
        }

        final RoomColumnInfo columnInfo = new RoomColumnInfo(sharedRealm.getPath(), table);

        if (!table.hasPrimaryKey()) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Primary key not defined for field 'ID' in existing Realm file. @PrimaryKey was added.");
        } else {
            if (table.getPrimaryKey() != columnInfo.IDIndex) {
                throw new RealmMigrationNeededException(sharedRealm.getPath(), "Primary Key annotation definition was changed, from field " + table.getColumnName(table.getPrimaryKey()) + " to field ID");
            }
        }

        if (!columnTypes.containsKey("ID")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Missing field 'ID' in existing Realm file. Either remove field or migrate using io.realm.internal.Table.addColumn().");
        }
        if (columnTypes.get("ID") != RealmFieldType.INTEGER) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Invalid type 'int' for field 'ID' in existing Realm file.");
        }
        if (table.isColumnNullable(columnInfo.IDIndex) && table.findFirstNull(columnInfo.IDIndex) != Table.NO_MATCH) {
            throw new IllegalStateException("Cannot migrate an object with null value in field 'ID'. Either maintain the same type for primary key field 'ID', or remove the object with null value before migration.");
        }
        if (!table.hasSearchIndex(table.getColumnIndex("ID"))) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Index not defined for field 'ID' in existing Realm file. Either set @Index or migrate using io.realm.internal.Table.removeSearchIndex().");
        }
        if (!columnTypes.containsKey("Name")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Missing field 'Name' in existing Realm file. Either remove field or migrate using io.realm.internal.Table.addColumn().");
        }
        if (columnTypes.get("Name") != RealmFieldType.STRING) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Invalid type 'String' for field 'Name' in existing Realm file.");
        }
        if (!table.isColumnNullable(columnInfo.NameIndex)) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Field 'Name' is required. Either set @Required to field 'Name' or migrate using RealmObjectSchema.setNullable().");
        }
        if (!columnTypes.containsKey("Location")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Missing field 'Location' in existing Realm file. Either remove field or migrate using io.realm.internal.Table.addColumn().");
        }
        if (columnTypes.get("Location") != RealmFieldType.OBJECT) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Invalid type 'Building' for field 'Location'");
        }
        if (!sharedRealm.hasTable("class_Building")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Missing class 'class_Building' for field 'Location'");
        }
        Table table_2 = sharedRealm.getTable("class_Building");
        if (!table.getLinkTarget(columnInfo.LocationIndex).hasSameSchema(table_2)) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Invalid RealmObject for field 'Location': '" + table.getLinkTarget(columnInfo.LocationIndex).getName() + "' expected - was '" + table_2.getName() + "'");
        }

        return columnInfo;
    }

    public static String getTableName() {
        return "class_Room";
    }

    public static List<String> getFieldNames() {
        return FIELD_NAMES;
    }

    @SuppressWarnings("cast")
    public static edu.bfa.ss.qin.Util.Room createOrUpdateUsingJsonObject(Realm realm, JSONObject json, boolean update)
        throws JSONException {
        final List<String> excludeFields = new ArrayList<String>(1);
        edu.bfa.ss.qin.Util.Room obj = null;
        if (update) {
            Table table = realm.getTable(edu.bfa.ss.qin.Util.Room.class);
            long pkColumnIndex = table.getPrimaryKey();
            long rowIndex = Table.NO_MATCH;
            if (!json.isNull("ID")) {
                rowIndex = table.findFirstLong(pkColumnIndex, json.getLong("ID"));
            }
            if (rowIndex != Table.NO_MATCH) {
                final BaseRealm.RealmObjectContext objectContext = BaseRealm.objectContext.get();
                try {
                    objectContext.set(realm, table.getUncheckedRow(rowIndex), realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Room.class), false, Collections.<String> emptyList());
                    obj = new io.realm.RoomRealmProxy();
                } finally {
                    objectContext.clear();
                }
            }
        }
        if (obj == null) {
            if (json.has("Location")) {
                excludeFields.add("Location");
            }
            if (json.has("ID")) {
                if (json.isNull("ID")) {
                    obj = (io.realm.RoomRealmProxy) realm.createObjectInternal(edu.bfa.ss.qin.Util.Room.class, null, true, excludeFields);
                } else {
                    obj = (io.realm.RoomRealmProxy) realm.createObjectInternal(edu.bfa.ss.qin.Util.Room.class, json.getInt("ID"), true, excludeFields);
                }
            } else {
                throw new IllegalArgumentException("JSON object doesn't have the primary key field 'ID'.");
            }
        }
        if (json.has("Name")) {
            if (json.isNull("Name")) {
                ((RoomRealmProxyInterface) obj).realmSet$Name(null);
            } else {
                ((RoomRealmProxyInterface) obj).realmSet$Name((String) json.getString("Name"));
            }
        }
        if (json.has("Location")) {
            if (json.isNull("Location")) {
                ((RoomRealmProxyInterface) obj).realmSet$Location(null);
            } else {
                edu.bfa.ss.qin.Util.Building LocationObj = BuildingRealmProxy.createOrUpdateUsingJsonObject(realm, json.getJSONObject("Location"), update);
                ((RoomRealmProxyInterface) obj).realmSet$Location(LocationObj);
            }
        }
        return obj;
    }

    @SuppressWarnings("cast")
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public static edu.bfa.ss.qin.Util.Room createUsingJsonStream(Realm realm, JsonReader reader)
        throws IOException {
        boolean jsonHasPrimaryKey = false;
        edu.bfa.ss.qin.Util.Room obj = new edu.bfa.ss.qin.Util.Room();
        reader.beginObject();
        while (reader.hasNext()) {
            String name = reader.nextName();
            if (false) {
            } else if (name.equals("ID")) {
                if (reader.peek() == JsonToken.NULL) {
                    reader.skipValue();
                    throw new IllegalArgumentException("Trying to set non-nullable field 'ID' to null.");
                } else {
                    ((RoomRealmProxyInterface) obj).realmSet$ID((int) reader.nextInt());
                }
                jsonHasPrimaryKey = true;
            } else if (name.equals("Name")) {
                if (reader.peek() == JsonToken.NULL) {
                    reader.skipValue();
                    ((RoomRealmProxyInterface) obj).realmSet$Name(null);
                } else {
                    ((RoomRealmProxyInterface) obj).realmSet$Name((String) reader.nextString());
                }
            } else if (name.equals("Location")) {
                if (reader.peek() == JsonToken.NULL) {
                    reader.skipValue();
                    ((RoomRealmProxyInterface) obj).realmSet$Location(null);
                } else {
                    edu.bfa.ss.qin.Util.Building LocationObj = BuildingRealmProxy.createUsingJsonStream(realm, reader);
                    ((RoomRealmProxyInterface) obj).realmSet$Location(LocationObj);
                }
            } else {
                reader.skipValue();
            }
        }
        reader.endObject();
        if (!jsonHasPrimaryKey) {
            throw new IllegalArgumentException("JSON object doesn't have the primary key field 'ID'.");
        }
        obj = realm.copyToRealm(obj);
        return obj;
    }

    public static edu.bfa.ss.qin.Util.Room copyOrUpdate(Realm realm, edu.bfa.ss.qin.Util.Room object, boolean update, Map<RealmModel,RealmObjectProxy> cache) {
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy) object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy) object).realmGet$proxyState().getRealm$realm().threadId != realm.threadId) {
            throw new IllegalArgumentException("Objects which belong to Realm instances in other threads cannot be copied into this Realm instance.");
        }
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
            return object;
        }
        final BaseRealm.RealmObjectContext objectContext = BaseRealm.objectContext.get();
        RealmObjectProxy cachedRealmObject = cache.get(object);
        if (cachedRealmObject != null) {
            return (edu.bfa.ss.qin.Util.Room) cachedRealmObject;
        } else {
            edu.bfa.ss.qin.Util.Room realmObject = null;
            boolean canUpdate = update;
            if (canUpdate) {
                Table table = realm.getTable(edu.bfa.ss.qin.Util.Room.class);
                long pkColumnIndex = table.getPrimaryKey();
                long rowIndex = table.findFirstLong(pkColumnIndex, ((RoomRealmProxyInterface) object).realmGet$ID());
                if (rowIndex != Table.NO_MATCH) {
                    try {
                        objectContext.set(realm, table.getUncheckedRow(rowIndex), realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Room.class), false, Collections.<String> emptyList());
                        realmObject = new io.realm.RoomRealmProxy();
                        cache.put(object, (RealmObjectProxy) realmObject);
                    } finally {
                        objectContext.clear();
                    }
                } else {
                    canUpdate = false;
                }
            }

            if (canUpdate) {
                return update(realm, realmObject, object, cache);
            } else {
                return copy(realm, object, update, cache);
            }
        }
    }

    public static edu.bfa.ss.qin.Util.Room copy(Realm realm, edu.bfa.ss.qin.Util.Room newObject, boolean update, Map<RealmModel,RealmObjectProxy> cache) {
        RealmObjectProxy cachedRealmObject = cache.get(newObject);
        if (cachedRealmObject != null) {
            return (edu.bfa.ss.qin.Util.Room) cachedRealmObject;
        } else {
            // rejecting default values to avoid creating unexpected objects from RealmModel/RealmList fields.
            edu.bfa.ss.qin.Util.Room realmObject = realm.createObjectInternal(edu.bfa.ss.qin.Util.Room.class, ((RoomRealmProxyInterface) newObject).realmGet$ID(), false, Collections.<String>emptyList());
            cache.put(newObject, (RealmObjectProxy) realmObject);
            ((RoomRealmProxyInterface) realmObject).realmSet$Name(((RoomRealmProxyInterface) newObject).realmGet$Name());

            edu.bfa.ss.qin.Util.Building LocationObj = ((RoomRealmProxyInterface) newObject).realmGet$Location();
            if (LocationObj != null) {
                edu.bfa.ss.qin.Util.Building cacheLocation = (edu.bfa.ss.qin.Util.Building) cache.get(LocationObj);
                if (cacheLocation != null) {
                    ((RoomRealmProxyInterface) realmObject).realmSet$Location(cacheLocation);
                } else {
                    ((RoomRealmProxyInterface) realmObject).realmSet$Location(BuildingRealmProxy.copyOrUpdate(realm, LocationObj, update, cache));
                }
            } else {
                ((RoomRealmProxyInterface) realmObject).realmSet$Location(null);
            }
            return realmObject;
        }
    }

    public static long insert(Realm realm, edu.bfa.ss.qin.Util.Room object, Map<RealmModel,Long> cache) {
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
            return ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex();
        }
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Room.class);
        long tableNativePtr = table.getNativeTablePointer();
        RoomColumnInfo columnInfo = (RoomColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Room.class);
        long pkColumnIndex = table.getPrimaryKey();
        long rowIndex = Table.NO_MATCH;
        Object primaryKeyValue = ((RoomRealmProxyInterface) object).realmGet$ID();
        if (primaryKeyValue != null) {
            rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((RoomRealmProxyInterface) object).realmGet$ID());
        }
        if (rowIndex == Table.NO_MATCH) {
            rowIndex = table.addEmptyRowWithPrimaryKey(((RoomRealmProxyInterface) object).realmGet$ID(), false);
        } else {
            Table.throwDuplicatePrimaryKeyException(primaryKeyValue);
        }
        cache.put(object, rowIndex);
        String realmGet$Name = ((RoomRealmProxyInterface)object).realmGet$Name();
        if (realmGet$Name != null) {
            Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
        }

        edu.bfa.ss.qin.Util.Building LocationObj = ((RoomRealmProxyInterface) object).realmGet$Location();
        if (LocationObj != null) {
            Long cacheLocation = cache.get(LocationObj);
            if (cacheLocation == null) {
                cacheLocation = BuildingRealmProxy.insert(realm, LocationObj, cache);
            }
            Table.nativeSetLink(tableNativePtr, columnInfo.LocationIndex, rowIndex, cacheLocation, false);
        }
        return rowIndex;
    }

    public static void insert(Realm realm, Iterator<? extends RealmModel> objects, Map<RealmModel,Long> cache) {
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Room.class);
        long tableNativePtr = table.getNativeTablePointer();
        RoomColumnInfo columnInfo = (RoomColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Room.class);
        long pkColumnIndex = table.getPrimaryKey();
        edu.bfa.ss.qin.Util.Room object = null;
        while (objects.hasNext()) {
            object = (edu.bfa.ss.qin.Util.Room) objects.next();
            if(!cache.containsKey(object)) {
                if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
                    cache.put(object, ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex());
                    continue;
                }
                long rowIndex = Table.NO_MATCH;
                Object primaryKeyValue = ((RoomRealmProxyInterface) object).realmGet$ID();
                if (primaryKeyValue != null) {
                    rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((RoomRealmProxyInterface) object).realmGet$ID());
                }
                if (rowIndex == Table.NO_MATCH) {
                    rowIndex = table.addEmptyRowWithPrimaryKey(((RoomRealmProxyInterface) object).realmGet$ID(), false);
                } else {
                    Table.throwDuplicatePrimaryKeyException(primaryKeyValue);
                }
                cache.put(object, rowIndex);
                String realmGet$Name = ((RoomRealmProxyInterface)object).realmGet$Name();
                if (realmGet$Name != null) {
                    Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
                }

                edu.bfa.ss.qin.Util.Building LocationObj = ((RoomRealmProxyInterface) object).realmGet$Location();
                if (LocationObj != null) {
                    Long cacheLocation = cache.get(LocationObj);
                    if (cacheLocation == null) {
                        cacheLocation = BuildingRealmProxy.insert(realm, LocationObj, cache);
                    }
                    table.setLink(columnInfo.LocationIndex, rowIndex, cacheLocation, false);
                }
            }
        }
    }

    public static long insertOrUpdate(Realm realm, edu.bfa.ss.qin.Util.Room object, Map<RealmModel,Long> cache) {
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
            return ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex();
        }
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Room.class);
        long tableNativePtr = table.getNativeTablePointer();
        RoomColumnInfo columnInfo = (RoomColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Room.class);
        long pkColumnIndex = table.getPrimaryKey();
        long rowIndex = Table.NO_MATCH;
        Object primaryKeyValue = ((RoomRealmProxyInterface) object).realmGet$ID();
        if (primaryKeyValue != null) {
            rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((RoomRealmProxyInterface) object).realmGet$ID());
        }
        if (rowIndex == Table.NO_MATCH) {
            rowIndex = table.addEmptyRowWithPrimaryKey(((RoomRealmProxyInterface) object).realmGet$ID(), false);
        }
        cache.put(object, rowIndex);
        String realmGet$Name = ((RoomRealmProxyInterface)object).realmGet$Name();
        if (realmGet$Name != null) {
            Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
        } else {
            Table.nativeSetNull(tableNativePtr, columnInfo.NameIndex, rowIndex, false);
        }

        edu.bfa.ss.qin.Util.Building LocationObj = ((RoomRealmProxyInterface) object).realmGet$Location();
        if (LocationObj != null) {
            Long cacheLocation = cache.get(LocationObj);
            if (cacheLocation == null) {
                cacheLocation = BuildingRealmProxy.insertOrUpdate(realm, LocationObj, cache);
            }
            Table.nativeSetLink(tableNativePtr, columnInfo.LocationIndex, rowIndex, cacheLocation, false);
        } else {
            Table.nativeNullifyLink(tableNativePtr, columnInfo.LocationIndex, rowIndex);
        }
        return rowIndex;
    }

    public static void insertOrUpdate(Realm realm, Iterator<? extends RealmModel> objects, Map<RealmModel,Long> cache) {
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Room.class);
        long tableNativePtr = table.getNativeTablePointer();
        RoomColumnInfo columnInfo = (RoomColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Room.class);
        long pkColumnIndex = table.getPrimaryKey();
        edu.bfa.ss.qin.Util.Room object = null;
        while (objects.hasNext()) {
            object = (edu.bfa.ss.qin.Util.Room) objects.next();
            if(!cache.containsKey(object)) {
                if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
                    cache.put(object, ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex());
                    continue;
                }
                long rowIndex = Table.NO_MATCH;
                Object primaryKeyValue = ((RoomRealmProxyInterface) object).realmGet$ID();
                if (primaryKeyValue != null) {
                    rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((RoomRealmProxyInterface) object).realmGet$ID());
                }
                if (rowIndex == Table.NO_MATCH) {
                    rowIndex = table.addEmptyRowWithPrimaryKey(((RoomRealmProxyInterface) object).realmGet$ID(), false);
                }
                cache.put(object, rowIndex);
                String realmGet$Name = ((RoomRealmProxyInterface)object).realmGet$Name();
                if (realmGet$Name != null) {
                    Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
                } else {
                    Table.nativeSetNull(tableNativePtr, columnInfo.NameIndex, rowIndex, false);
                }

                edu.bfa.ss.qin.Util.Building LocationObj = ((RoomRealmProxyInterface) object).realmGet$Location();
                if (LocationObj != null) {
                    Long cacheLocation = cache.get(LocationObj);
                    if (cacheLocation == null) {
                        cacheLocation = BuildingRealmProxy.insertOrUpdate(realm, LocationObj, cache);
                    }
                    Table.nativeSetLink(tableNativePtr, columnInfo.LocationIndex, rowIndex, cacheLocation, false);
                } else {
                    Table.nativeNullifyLink(tableNativePtr, columnInfo.LocationIndex, rowIndex);
                }
            }
        }
    }

    public static edu.bfa.ss.qin.Util.Room createDetachedCopy(edu.bfa.ss.qin.Util.Room realmObject, int currentDepth, int maxDepth, Map<RealmModel, CacheData<RealmModel>> cache) {
        if (currentDepth > maxDepth || realmObject == null) {
            return null;
        }
        CacheData<RealmModel> cachedObject = cache.get(realmObject);
        edu.bfa.ss.qin.Util.Room unmanagedObject;
        if (cachedObject != null) {
            // Reuse cached object or recreate it because it was encountered at a lower depth.
            if (currentDepth >= cachedObject.minDepth) {
                return (edu.bfa.ss.qin.Util.Room)cachedObject.object;
            } else {
                unmanagedObject = (edu.bfa.ss.qin.Util.Room)cachedObject.object;
                cachedObject.minDepth = currentDepth;
            }
        } else {
            unmanagedObject = new edu.bfa.ss.qin.Util.Room();
            cache.put(realmObject, new RealmObjectProxy.CacheData<RealmModel>(currentDepth, unmanagedObject));
        }
        ((RoomRealmProxyInterface) unmanagedObject).realmSet$ID(((RoomRealmProxyInterface) realmObject).realmGet$ID());
        ((RoomRealmProxyInterface) unmanagedObject).realmSet$Name(((RoomRealmProxyInterface) realmObject).realmGet$Name());

        // Deep copy of Location
        ((RoomRealmProxyInterface) unmanagedObject).realmSet$Location(BuildingRealmProxy.createDetachedCopy(((RoomRealmProxyInterface) realmObject).realmGet$Location(), currentDepth + 1, maxDepth, cache));
        return unmanagedObject;
    }

    static edu.bfa.ss.qin.Util.Room update(Realm realm, edu.bfa.ss.qin.Util.Room realmObject, edu.bfa.ss.qin.Util.Room newObject, Map<RealmModel, RealmObjectProxy> cache) {
        ((RoomRealmProxyInterface) realmObject).realmSet$Name(((RoomRealmProxyInterface) newObject).realmGet$Name());
        edu.bfa.ss.qin.Util.Building LocationObj = ((RoomRealmProxyInterface) newObject).realmGet$Location();
        if (LocationObj != null) {
            edu.bfa.ss.qin.Util.Building cacheLocation = (edu.bfa.ss.qin.Util.Building) cache.get(LocationObj);
            if (cacheLocation != null) {
                ((RoomRealmProxyInterface) realmObject).realmSet$Location(cacheLocation);
            } else {
                ((RoomRealmProxyInterface) realmObject).realmSet$Location(BuildingRealmProxy.copyOrUpdate(realm, LocationObj, true, cache));
            }
        } else {
            ((RoomRealmProxyInterface) realmObject).realmSet$Location(null);
        }
        return realmObject;
    }

    @Override
    @SuppressWarnings("ArrayToString")
    public String toString() {
        if (!RealmObject.isValid(this)) {
            return "Invalid object";
        }
        StringBuilder stringBuilder = new StringBuilder("Room = [");
        stringBuilder.append("{ID:");
        stringBuilder.append(realmGet$ID());
        stringBuilder.append("}");
        stringBuilder.append(",");
        stringBuilder.append("{Name:");
        stringBuilder.append(realmGet$Name() != null ? realmGet$Name() : "null");
        stringBuilder.append("}");
        stringBuilder.append(",");
        stringBuilder.append("{Location:");
        stringBuilder.append(realmGet$Location() != null ? "Building" : "null");
        stringBuilder.append("}");
        stringBuilder.append("]");
        return stringBuilder.toString();
    }

    @Override
    public ProxyState<?> realmGet$proxyState() {
        return proxyState;
    }

    @Override
    public int hashCode() {
        String realmName = proxyState.getRealm$realm().getPath();
        String tableName = proxyState.getRow$realm().getTable().getName();
        long rowIndex = proxyState.getRow$realm().getIndex();

        int result = 17;
        result = 31 * result + ((realmName != null) ? realmName.hashCode() : 0);
        result = 31 * result + ((tableName != null) ? tableName.hashCode() : 0);
        result = 31 * result + (int) (rowIndex ^ (rowIndex >>> 32));
        return result;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RoomRealmProxy aRoom = (RoomRealmProxy)o;

        String path = proxyState.getRealm$realm().getPath();
        String otherPath = aRoom.proxyState.getRealm$realm().getPath();
        if (path != null ? !path.equals(otherPath) : otherPath != null) return false;

        String tableName = proxyState.getRow$realm().getTable().getName();
        String otherTableName = aRoom.proxyState.getRow$realm().getTable().getName();
        if (tableName != null ? !tableName.equals(otherTableName) : otherTableName != null) return false;

        if (proxyState.getRow$realm().getIndex() != aRoom.proxyState.getRow$realm().getIndex()) return false;

        return true;
    }

}
