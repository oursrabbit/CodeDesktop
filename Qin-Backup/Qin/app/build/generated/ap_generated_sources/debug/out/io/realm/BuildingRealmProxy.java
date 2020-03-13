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

public class BuildingRealmProxy extends edu.bfa.ss.qin.Util.Building
    implements RealmObjectProxy, BuildingRealmProxyInterface {

    static final class BuildingColumnInfo extends ColumnInfo
        implements Cloneable {

        public long IDIndex;
        public long NameIndex;
        public long RoomsIndex;

        BuildingColumnInfo(String path, Table table) {
            final Map<String, Long> indicesMap = new HashMap<String, Long>(3);
            this.IDIndex = getValidColumnIndex(path, table, "Building", "ID");
            indicesMap.put("ID", this.IDIndex);
            this.NameIndex = getValidColumnIndex(path, table, "Building", "Name");
            indicesMap.put("Name", this.NameIndex);
            this.RoomsIndex = getValidColumnIndex(path, table, "Building", "Rooms");
            indicesMap.put("Rooms", this.RoomsIndex);

            setIndicesMap(indicesMap);
        }

        @Override
        public final void copyColumnInfoFrom(ColumnInfo other) {
            final BuildingColumnInfo otherInfo = (BuildingColumnInfo) other;
            this.IDIndex = otherInfo.IDIndex;
            this.NameIndex = otherInfo.NameIndex;
            this.RoomsIndex = otherInfo.RoomsIndex;

            setIndicesMap(otherInfo.getIndicesMap());
        }

        @Override
        public final BuildingColumnInfo clone() {
            return (BuildingColumnInfo) super.clone();
        }

    }
    private BuildingColumnInfo columnInfo;
    private ProxyState<edu.bfa.ss.qin.Util.Building> proxyState;
    private RealmList<edu.bfa.ss.qin.Util.Room> RoomsRealmList;
    private static final List<String> FIELD_NAMES;
    static {
        List<String> fieldNames = new ArrayList<String>();
        fieldNames.add("ID");
        fieldNames.add("Name");
        fieldNames.add("Rooms");
        FIELD_NAMES = Collections.unmodifiableList(fieldNames);
    }

    BuildingRealmProxy() {
        proxyState.setConstructionFinished();
    }

    @Override
    public void realm$injectObjectContext() {
        if (this.proxyState != null) {
            return;
        }
        final BaseRealm.RealmObjectContext context = BaseRealm.objectContext.get();
        this.columnInfo = (BuildingColumnInfo) context.getColumnInfo();
        this.proxyState = new ProxyState<edu.bfa.ss.qin.Util.Building>(this);
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
    public RealmList<edu.bfa.ss.qin.Util.Room> realmGet$Rooms() {
        proxyState.getRealm$realm().checkIfValid();
        // use the cached value if available
        if (RoomsRealmList != null) {
            return RoomsRealmList;
        } else {
            LinkView linkView = proxyState.getRow$realm().getLinkList(columnInfo.RoomsIndex);
            RoomsRealmList = new RealmList<edu.bfa.ss.qin.Util.Room>(edu.bfa.ss.qin.Util.Room.class, linkView, proxyState.getRealm$realm());
            return RoomsRealmList;
        }
    }

    @Override
    public void realmSet$Rooms(RealmList<edu.bfa.ss.qin.Util.Room> value) {
        if (proxyState.isUnderConstruction()) {
            if (!proxyState.getAcceptDefaultValue$realm()) {
                return;
            }
            if (proxyState.getExcludeFields$realm().contains("Rooms")) {
                return;
            }
            if (value != null && !value.isManaged()) {
                final Realm realm = (Realm) proxyState.getRealm$realm();
                final RealmList<edu.bfa.ss.qin.Util.Room> original = value;
                value = new RealmList<edu.bfa.ss.qin.Util.Room>();
                for (edu.bfa.ss.qin.Util.Room item : original) {
                    if (item == null || RealmObject.isManaged(item)) {
                        value.add(item);
                    } else {
                        value.add(realm.copyToRealm(item));
                    }
                }
            }
        }

        proxyState.getRealm$realm().checkIfValid();
        LinkView links = proxyState.getRow$realm().getLinkList(columnInfo.RoomsIndex);
        links.clear();
        if (value == null) {
            return;
        }
        for (RealmModel linkedObject : (RealmList<? extends RealmModel>) value) {
            if (!(RealmObject.isManaged(linkedObject) && RealmObject.isValid(linkedObject))) {
                throw new IllegalArgumentException("Each element of 'value' must be a valid managed object.");
            }
            if (((RealmObjectProxy)linkedObject).realmGet$proxyState().getRealm$realm() != proxyState.getRealm$realm()) {
                throw new IllegalArgumentException("Each element of 'value' must belong to the same Realm.");
            }
            links.add(((RealmObjectProxy)linkedObject).realmGet$proxyState().getRow$realm().getIndex());
        }
    }

    public static RealmObjectSchema createRealmObjectSchema(RealmSchema realmSchema) {
        if (!realmSchema.contains("Building")) {
            RealmObjectSchema realmObjectSchema = realmSchema.create("Building");
            realmObjectSchema.add("ID", RealmFieldType.INTEGER, Property.PRIMARY_KEY, Property.INDEXED, Property.REQUIRED);
            realmObjectSchema.add("Name", RealmFieldType.STRING, !Property.PRIMARY_KEY, !Property.INDEXED, !Property.REQUIRED);
            if (!realmSchema.contains("Room")) {
                RoomRealmProxy.createRealmObjectSchema(realmSchema);
            }
            realmObjectSchema.add("Rooms", RealmFieldType.LIST, realmSchema.get("Room"));
            return realmObjectSchema;
        }
        return realmSchema.get("Building");
    }

    public static BuildingColumnInfo validateTable(SharedRealm sharedRealm, boolean allowExtraColumns) {
        if (!sharedRealm.hasTable("class_Building")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "The 'Building' class is missing from the schema for this Realm.");
        }
        Table table = sharedRealm.getTable("class_Building");
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

        final BuildingColumnInfo columnInfo = new BuildingColumnInfo(sharedRealm.getPath(), table);

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
        if (!columnTypes.containsKey("Rooms")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Missing field 'Rooms'");
        }
        if (columnTypes.get("Rooms") != RealmFieldType.LIST) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Invalid type 'Room' for field 'Rooms'");
        }
        if (!sharedRealm.hasTable("class_Room")) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Missing class 'class_Room' for field 'Rooms'");
        }
        Table table_2 = sharedRealm.getTable("class_Room");
        if (!table.getLinkTarget(columnInfo.RoomsIndex).hasSameSchema(table_2)) {
            throw new RealmMigrationNeededException(sharedRealm.getPath(), "Invalid RealmList type for field 'Rooms': '" + table.getLinkTarget(columnInfo.RoomsIndex).getName() + "' expected - was '" + table_2.getName() + "'");
        }

        return columnInfo;
    }

    public static String getTableName() {
        return "class_Building";
    }

    public static List<String> getFieldNames() {
        return FIELD_NAMES;
    }

    @SuppressWarnings("cast")
    public static edu.bfa.ss.qin.Util.Building createOrUpdateUsingJsonObject(Realm realm, JSONObject json, boolean update)
        throws JSONException {
        final List<String> excludeFields = new ArrayList<String>(1);
        edu.bfa.ss.qin.Util.Building obj = null;
        if (update) {
            Table table = realm.getTable(edu.bfa.ss.qin.Util.Building.class);
            long pkColumnIndex = table.getPrimaryKey();
            long rowIndex = Table.NO_MATCH;
            if (!json.isNull("ID")) {
                rowIndex = table.findFirstLong(pkColumnIndex, json.getLong("ID"));
            }
            if (rowIndex != Table.NO_MATCH) {
                final BaseRealm.RealmObjectContext objectContext = BaseRealm.objectContext.get();
                try {
                    objectContext.set(realm, table.getUncheckedRow(rowIndex), realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Building.class), false, Collections.<String> emptyList());
                    obj = new io.realm.BuildingRealmProxy();
                } finally {
                    objectContext.clear();
                }
            }
        }
        if (obj == null) {
            if (json.has("Rooms")) {
                excludeFields.add("Rooms");
            }
            if (json.has("ID")) {
                if (json.isNull("ID")) {
                    obj = (io.realm.BuildingRealmProxy) realm.createObjectInternal(edu.bfa.ss.qin.Util.Building.class, null, true, excludeFields);
                } else {
                    obj = (io.realm.BuildingRealmProxy) realm.createObjectInternal(edu.bfa.ss.qin.Util.Building.class, json.getInt("ID"), true, excludeFields);
                }
            } else {
                throw new IllegalArgumentException("JSON object doesn't have the primary key field 'ID'.");
            }
        }
        if (json.has("Name")) {
            if (json.isNull("Name")) {
                ((BuildingRealmProxyInterface) obj).realmSet$Name(null);
            } else {
                ((BuildingRealmProxyInterface) obj).realmSet$Name((String) json.getString("Name"));
            }
        }
        if (json.has("Rooms")) {
            if (json.isNull("Rooms")) {
                ((BuildingRealmProxyInterface) obj).realmSet$Rooms(null);
            } else {
                ((BuildingRealmProxyInterface) obj).realmGet$Rooms().clear();
                JSONArray array = json.getJSONArray("Rooms");
                for (int i = 0; i < array.length(); i++) {
                    edu.bfa.ss.qin.Util.Room item = RoomRealmProxy.createOrUpdateUsingJsonObject(realm, array.getJSONObject(i), update);
                    ((BuildingRealmProxyInterface) obj).realmGet$Rooms().add(item);
                }
            }
        }
        return obj;
    }

    @SuppressWarnings("cast")
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    public static edu.bfa.ss.qin.Util.Building createUsingJsonStream(Realm realm, JsonReader reader)
        throws IOException {
        boolean jsonHasPrimaryKey = false;
        edu.bfa.ss.qin.Util.Building obj = new edu.bfa.ss.qin.Util.Building();
        reader.beginObject();
        while (reader.hasNext()) {
            String name = reader.nextName();
            if (false) {
            } else if (name.equals("ID")) {
                if (reader.peek() == JsonToken.NULL) {
                    reader.skipValue();
                    throw new IllegalArgumentException("Trying to set non-nullable field 'ID' to null.");
                } else {
                    ((BuildingRealmProxyInterface) obj).realmSet$ID((int) reader.nextInt());
                }
                jsonHasPrimaryKey = true;
            } else if (name.equals("Name")) {
                if (reader.peek() == JsonToken.NULL) {
                    reader.skipValue();
                    ((BuildingRealmProxyInterface) obj).realmSet$Name(null);
                } else {
                    ((BuildingRealmProxyInterface) obj).realmSet$Name((String) reader.nextString());
                }
            } else if (name.equals("Rooms")) {
                if (reader.peek() == JsonToken.NULL) {
                    reader.skipValue();
                    ((BuildingRealmProxyInterface) obj).realmSet$Rooms(null);
                } else {
                    ((BuildingRealmProxyInterface) obj).realmSet$Rooms(new RealmList<edu.bfa.ss.qin.Util.Room>());
                    reader.beginArray();
                    while (reader.hasNext()) {
                        edu.bfa.ss.qin.Util.Room item = RoomRealmProxy.createUsingJsonStream(realm, reader);
                        ((BuildingRealmProxyInterface) obj).realmGet$Rooms().add(item);
                    }
                    reader.endArray();
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

    public static edu.bfa.ss.qin.Util.Building copyOrUpdate(Realm realm, edu.bfa.ss.qin.Util.Building object, boolean update, Map<RealmModel,RealmObjectProxy> cache) {
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy) object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy) object).realmGet$proxyState().getRealm$realm().threadId != realm.threadId) {
            throw new IllegalArgumentException("Objects which belong to Realm instances in other threads cannot be copied into this Realm instance.");
        }
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
            return object;
        }
        final BaseRealm.RealmObjectContext objectContext = BaseRealm.objectContext.get();
        RealmObjectProxy cachedRealmObject = cache.get(object);
        if (cachedRealmObject != null) {
            return (edu.bfa.ss.qin.Util.Building) cachedRealmObject;
        } else {
            edu.bfa.ss.qin.Util.Building realmObject = null;
            boolean canUpdate = update;
            if (canUpdate) {
                Table table = realm.getTable(edu.bfa.ss.qin.Util.Building.class);
                long pkColumnIndex = table.getPrimaryKey();
                long rowIndex = table.findFirstLong(pkColumnIndex, ((BuildingRealmProxyInterface) object).realmGet$ID());
                if (rowIndex != Table.NO_MATCH) {
                    try {
                        objectContext.set(realm, table.getUncheckedRow(rowIndex), realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Building.class), false, Collections.<String> emptyList());
                        realmObject = new io.realm.BuildingRealmProxy();
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

    public static edu.bfa.ss.qin.Util.Building copy(Realm realm, edu.bfa.ss.qin.Util.Building newObject, boolean update, Map<RealmModel,RealmObjectProxy> cache) {
        RealmObjectProxy cachedRealmObject = cache.get(newObject);
        if (cachedRealmObject != null) {
            return (edu.bfa.ss.qin.Util.Building) cachedRealmObject;
        } else {
            // rejecting default values to avoid creating unexpected objects from RealmModel/RealmList fields.
            edu.bfa.ss.qin.Util.Building realmObject = realm.createObjectInternal(edu.bfa.ss.qin.Util.Building.class, ((BuildingRealmProxyInterface) newObject).realmGet$ID(), false, Collections.<String>emptyList());
            cache.put(newObject, (RealmObjectProxy) realmObject);
            ((BuildingRealmProxyInterface) realmObject).realmSet$Name(((BuildingRealmProxyInterface) newObject).realmGet$Name());

            RealmList<edu.bfa.ss.qin.Util.Room> RoomsList = ((BuildingRealmProxyInterface) newObject).realmGet$Rooms();
            if (RoomsList != null) {
                RealmList<edu.bfa.ss.qin.Util.Room> RoomsRealmList = ((BuildingRealmProxyInterface) realmObject).realmGet$Rooms();
                for (int i = 0; i < RoomsList.size(); i++) {
                    edu.bfa.ss.qin.Util.Room RoomsItem = RoomsList.get(i);
                    edu.bfa.ss.qin.Util.Room cacheRooms = (edu.bfa.ss.qin.Util.Room) cache.get(RoomsItem);
                    if (cacheRooms != null) {
                        RoomsRealmList.add(cacheRooms);
                    } else {
                        RoomsRealmList.add(RoomRealmProxy.copyOrUpdate(realm, RoomsList.get(i), update, cache));
                    }
                }
            }

            return realmObject;
        }
    }

    public static long insert(Realm realm, edu.bfa.ss.qin.Util.Building object, Map<RealmModel,Long> cache) {
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
            return ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex();
        }
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Building.class);
        long tableNativePtr = table.getNativeTablePointer();
        BuildingColumnInfo columnInfo = (BuildingColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Building.class);
        long pkColumnIndex = table.getPrimaryKey();
        long rowIndex = Table.NO_MATCH;
        Object primaryKeyValue = ((BuildingRealmProxyInterface) object).realmGet$ID();
        if (primaryKeyValue != null) {
            rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((BuildingRealmProxyInterface) object).realmGet$ID());
        }
        if (rowIndex == Table.NO_MATCH) {
            rowIndex = table.addEmptyRowWithPrimaryKey(((BuildingRealmProxyInterface) object).realmGet$ID(), false);
        } else {
            Table.throwDuplicatePrimaryKeyException(primaryKeyValue);
        }
        cache.put(object, rowIndex);
        String realmGet$Name = ((BuildingRealmProxyInterface)object).realmGet$Name();
        if (realmGet$Name != null) {
            Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
        }

        RealmList<edu.bfa.ss.qin.Util.Room> RoomsList = ((BuildingRealmProxyInterface) object).realmGet$Rooms();
        if (RoomsList != null) {
            long RoomsNativeLinkViewPtr = Table.nativeGetLinkView(tableNativePtr, columnInfo.RoomsIndex, rowIndex);
            for (edu.bfa.ss.qin.Util.Room RoomsItem : RoomsList) {
                Long cacheItemIndexRooms = cache.get(RoomsItem);
                if (cacheItemIndexRooms == null) {
                    cacheItemIndexRooms = RoomRealmProxy.insert(realm, RoomsItem, cache);
                }
                LinkView.nativeAdd(RoomsNativeLinkViewPtr, cacheItemIndexRooms);
            }
        }

        return rowIndex;
    }

    public static void insert(Realm realm, Iterator<? extends RealmModel> objects, Map<RealmModel,Long> cache) {
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Building.class);
        long tableNativePtr = table.getNativeTablePointer();
        BuildingColumnInfo columnInfo = (BuildingColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Building.class);
        long pkColumnIndex = table.getPrimaryKey();
        edu.bfa.ss.qin.Util.Building object = null;
        while (objects.hasNext()) {
            object = (edu.bfa.ss.qin.Util.Building) objects.next();
            if(!cache.containsKey(object)) {
                if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
                    cache.put(object, ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex());
                    continue;
                }
                long rowIndex = Table.NO_MATCH;
                Object primaryKeyValue = ((BuildingRealmProxyInterface) object).realmGet$ID();
                if (primaryKeyValue != null) {
                    rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((BuildingRealmProxyInterface) object).realmGet$ID());
                }
                if (rowIndex == Table.NO_MATCH) {
                    rowIndex = table.addEmptyRowWithPrimaryKey(((BuildingRealmProxyInterface) object).realmGet$ID(), false);
                } else {
                    Table.throwDuplicatePrimaryKeyException(primaryKeyValue);
                }
                cache.put(object, rowIndex);
                String realmGet$Name = ((BuildingRealmProxyInterface)object).realmGet$Name();
                if (realmGet$Name != null) {
                    Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
                }

                RealmList<edu.bfa.ss.qin.Util.Room> RoomsList = ((BuildingRealmProxyInterface) object).realmGet$Rooms();
                if (RoomsList != null) {
                    long RoomsNativeLinkViewPtr = Table.nativeGetLinkView(tableNativePtr, columnInfo.RoomsIndex, rowIndex);
                    for (edu.bfa.ss.qin.Util.Room RoomsItem : RoomsList) {
                        Long cacheItemIndexRooms = cache.get(RoomsItem);
                        if (cacheItemIndexRooms == null) {
                            cacheItemIndexRooms = RoomRealmProxy.insert(realm, RoomsItem, cache);
                        }
                        LinkView.nativeAdd(RoomsNativeLinkViewPtr, cacheItemIndexRooms);
                    }
                }

            }
        }
    }

    public static long insertOrUpdate(Realm realm, edu.bfa.ss.qin.Util.Building object, Map<RealmModel,Long> cache) {
        if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
            return ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex();
        }
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Building.class);
        long tableNativePtr = table.getNativeTablePointer();
        BuildingColumnInfo columnInfo = (BuildingColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Building.class);
        long pkColumnIndex = table.getPrimaryKey();
        long rowIndex = Table.NO_MATCH;
        Object primaryKeyValue = ((BuildingRealmProxyInterface) object).realmGet$ID();
        if (primaryKeyValue != null) {
            rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((BuildingRealmProxyInterface) object).realmGet$ID());
        }
        if (rowIndex == Table.NO_MATCH) {
            rowIndex = table.addEmptyRowWithPrimaryKey(((BuildingRealmProxyInterface) object).realmGet$ID(), false);
        }
        cache.put(object, rowIndex);
        String realmGet$Name = ((BuildingRealmProxyInterface)object).realmGet$Name();
        if (realmGet$Name != null) {
            Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
        } else {
            Table.nativeSetNull(tableNativePtr, columnInfo.NameIndex, rowIndex, false);
        }

        long RoomsNativeLinkViewPtr = Table.nativeGetLinkView(tableNativePtr, columnInfo.RoomsIndex, rowIndex);
        LinkView.nativeClear(RoomsNativeLinkViewPtr);
        RealmList<edu.bfa.ss.qin.Util.Room> RoomsList = ((BuildingRealmProxyInterface) object).realmGet$Rooms();
        if (RoomsList != null) {
            for (edu.bfa.ss.qin.Util.Room RoomsItem : RoomsList) {
                Long cacheItemIndexRooms = cache.get(RoomsItem);
                if (cacheItemIndexRooms == null) {
                    cacheItemIndexRooms = RoomRealmProxy.insertOrUpdate(realm, RoomsItem, cache);
                }
                LinkView.nativeAdd(RoomsNativeLinkViewPtr, cacheItemIndexRooms);
            }
        }

        return rowIndex;
    }

    public static void insertOrUpdate(Realm realm, Iterator<? extends RealmModel> objects, Map<RealmModel,Long> cache) {
        Table table = realm.getTable(edu.bfa.ss.qin.Util.Building.class);
        long tableNativePtr = table.getNativeTablePointer();
        BuildingColumnInfo columnInfo = (BuildingColumnInfo) realm.schema.getColumnInfo(edu.bfa.ss.qin.Util.Building.class);
        long pkColumnIndex = table.getPrimaryKey();
        edu.bfa.ss.qin.Util.Building object = null;
        while (objects.hasNext()) {
            object = (edu.bfa.ss.qin.Util.Building) objects.next();
            if(!cache.containsKey(object)) {
                if (object instanceof RealmObjectProxy && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm() != null && ((RealmObjectProxy)object).realmGet$proxyState().getRealm$realm().getPath().equals(realm.getPath())) {
                    cache.put(object, ((RealmObjectProxy)object).realmGet$proxyState().getRow$realm().getIndex());
                    continue;
                }
                long rowIndex = Table.NO_MATCH;
                Object primaryKeyValue = ((BuildingRealmProxyInterface) object).realmGet$ID();
                if (primaryKeyValue != null) {
                    rowIndex = Table.nativeFindFirstInt(tableNativePtr, pkColumnIndex, ((BuildingRealmProxyInterface) object).realmGet$ID());
                }
                if (rowIndex == Table.NO_MATCH) {
                    rowIndex = table.addEmptyRowWithPrimaryKey(((BuildingRealmProxyInterface) object).realmGet$ID(), false);
                }
                cache.put(object, rowIndex);
                String realmGet$Name = ((BuildingRealmProxyInterface)object).realmGet$Name();
                if (realmGet$Name != null) {
                    Table.nativeSetString(tableNativePtr, columnInfo.NameIndex, rowIndex, realmGet$Name, false);
                } else {
                    Table.nativeSetNull(tableNativePtr, columnInfo.NameIndex, rowIndex, false);
                }

                long RoomsNativeLinkViewPtr = Table.nativeGetLinkView(tableNativePtr, columnInfo.RoomsIndex, rowIndex);
                LinkView.nativeClear(RoomsNativeLinkViewPtr);
                RealmList<edu.bfa.ss.qin.Util.Room> RoomsList = ((BuildingRealmProxyInterface) object).realmGet$Rooms();
                if (RoomsList != null) {
                    for (edu.bfa.ss.qin.Util.Room RoomsItem : RoomsList) {
                        Long cacheItemIndexRooms = cache.get(RoomsItem);
                        if (cacheItemIndexRooms == null) {
                            cacheItemIndexRooms = RoomRealmProxy.insertOrUpdate(realm, RoomsItem, cache);
                        }
                        LinkView.nativeAdd(RoomsNativeLinkViewPtr, cacheItemIndexRooms);
                    }
                }

            }
        }
    }

    public static edu.bfa.ss.qin.Util.Building createDetachedCopy(edu.bfa.ss.qin.Util.Building realmObject, int currentDepth, int maxDepth, Map<RealmModel, CacheData<RealmModel>> cache) {
        if (currentDepth > maxDepth || realmObject == null) {
            return null;
        }
        CacheData<RealmModel> cachedObject = cache.get(realmObject);
        edu.bfa.ss.qin.Util.Building unmanagedObject;
        if (cachedObject != null) {
            // Reuse cached object or recreate it because it was encountered at a lower depth.
            if (currentDepth >= cachedObject.minDepth) {
                return (edu.bfa.ss.qin.Util.Building)cachedObject.object;
            } else {
                unmanagedObject = (edu.bfa.ss.qin.Util.Building)cachedObject.object;
                cachedObject.minDepth = currentDepth;
            }
        } else {
            unmanagedObject = new edu.bfa.ss.qin.Util.Building();
            cache.put(realmObject, new RealmObjectProxy.CacheData<RealmModel>(currentDepth, unmanagedObject));
        }
        ((BuildingRealmProxyInterface) unmanagedObject).realmSet$ID(((BuildingRealmProxyInterface) realmObject).realmGet$ID());
        ((BuildingRealmProxyInterface) unmanagedObject).realmSet$Name(((BuildingRealmProxyInterface) realmObject).realmGet$Name());

        // Deep copy of Rooms
        if (currentDepth == maxDepth) {
            ((BuildingRealmProxyInterface) unmanagedObject).realmSet$Rooms(null);
        } else {
            RealmList<edu.bfa.ss.qin.Util.Room> managedRoomsList = ((BuildingRealmProxyInterface) realmObject).realmGet$Rooms();
            RealmList<edu.bfa.ss.qin.Util.Room> unmanagedRoomsList = new RealmList<edu.bfa.ss.qin.Util.Room>();
            ((BuildingRealmProxyInterface) unmanagedObject).realmSet$Rooms(unmanagedRoomsList);
            int nextDepth = currentDepth + 1;
            int size = managedRoomsList.size();
            for (int i = 0; i < size; i++) {
                edu.bfa.ss.qin.Util.Room item = RoomRealmProxy.createDetachedCopy(managedRoomsList.get(i), nextDepth, maxDepth, cache);
                unmanagedRoomsList.add(item);
            }
        }
        return unmanagedObject;
    }

    static edu.bfa.ss.qin.Util.Building update(Realm realm, edu.bfa.ss.qin.Util.Building realmObject, edu.bfa.ss.qin.Util.Building newObject, Map<RealmModel, RealmObjectProxy> cache) {
        ((BuildingRealmProxyInterface) realmObject).realmSet$Name(((BuildingRealmProxyInterface) newObject).realmGet$Name());
        RealmList<edu.bfa.ss.qin.Util.Room> RoomsList = ((BuildingRealmProxyInterface) newObject).realmGet$Rooms();
        RealmList<edu.bfa.ss.qin.Util.Room> RoomsRealmList = ((BuildingRealmProxyInterface) realmObject).realmGet$Rooms();
        RoomsRealmList.clear();
        if (RoomsList != null) {
            for (int i = 0; i < RoomsList.size(); i++) {
                edu.bfa.ss.qin.Util.Room RoomsItem = RoomsList.get(i);
                edu.bfa.ss.qin.Util.Room cacheRooms = (edu.bfa.ss.qin.Util.Room) cache.get(RoomsItem);
                if (cacheRooms != null) {
                    RoomsRealmList.add(cacheRooms);
                } else {
                    RoomsRealmList.add(RoomRealmProxy.copyOrUpdate(realm, RoomsList.get(i), true, cache));
                }
            }
        }
        return realmObject;
    }

    @Override
    @SuppressWarnings("ArrayToString")
    public String toString() {
        if (!RealmObject.isValid(this)) {
            return "Invalid object";
        }
        StringBuilder stringBuilder = new StringBuilder("Building = [");
        stringBuilder.append("{ID:");
        stringBuilder.append(realmGet$ID());
        stringBuilder.append("}");
        stringBuilder.append(",");
        stringBuilder.append("{Name:");
        stringBuilder.append(realmGet$Name() != null ? realmGet$Name() : "null");
        stringBuilder.append("}");
        stringBuilder.append(",");
        stringBuilder.append("{Rooms:");
        stringBuilder.append("RealmList<Room>[").append(realmGet$Rooms().size()).append("]");
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
        BuildingRealmProxy aBuilding = (BuildingRealmProxy)o;

        String path = proxyState.getRealm$realm().getPath();
        String otherPath = aBuilding.proxyState.getRealm$realm().getPath();
        if (path != null ? !path.equals(otherPath) : otherPath != null) return false;

        String tableName = proxyState.getRow$realm().getTable().getName();
        String otherTableName = aBuilding.proxyState.getRow$realm().getTable().getName();
        if (tableName != null ? !tableName.equals(otherTableName) : otherTableName != null) return false;

        if (proxyState.getRow$realm().getIndex() != aBuilding.proxyState.getRow$realm().getIndex()) return false;

        return true;
    }

}
