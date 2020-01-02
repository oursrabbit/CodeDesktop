package edu.bfa.ss.qin;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.EditText;
import android.widget.ExpandableListView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.List;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Util.Building;
import edu.bfa.ss.qin.Util.Room;
import edu.bfa.ss.qin.Util.StaticData;
import io.realm.Realm;
import io.realm.RealmResults;

public class RoomListActivity extends AppCompatActivity {

    private RealmResults<Building> buildings;
    private RealmResults<Room> rooms;
    private Realm realm;
    private ExpandableListView buildingList;

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK)
            return false;
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_room_list_actionbar,menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        switch (item.getItemId()) {
            case R.id.RL_MENU_opensetting:
                final View convertView = LayoutInflater.from(this).inflate(R.layout.alterdialog_checkpassword, null);
                new InCanceledAlterDialog.Builder(RoomListActivity.this).setMessage("管理员验证")
                        .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                EditText pwtf = convertView.findViewById(R.id.FD_authorpassword);
                                if (pwtf.getText().toString().equals("111111")) {
                                    Intent intent = new Intent();
                                    intent.setClass(RoomListActivity.this, QinSettingActivity.class);
                                    startActivity(intent);
                                } else {
                                    new InCanceledAlterDialog.Builder(RoomListActivity.this).setTitle("验证失败").setMessage("请联系管理员修改个人信息").setNegativeButton("确定", null).show();
                                }
                            }
                        })
                        .setNegativeButton("取消", null)
                        .setView(convertView).show();
                return true;
            case R.id.RL_MENU_checklog:
                Intent intent = new Intent();
                intent.setClass(RoomListActivity.this, CheckDBActivity.class);
                startActivity(intent);
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_room_list);

        Realm.init(this);
        realm = Realm.getDefaultInstance();

        buildings = realm.where(Building.class).findAll();
        rooms = realm.where(Room.class).findAll();

        buildingList = findViewById(R.id.RL_roomlist);
        BuildingRoomAdapter adapter = new BuildingRoomAdapter(this, buildings);
        buildingList.setAdapter(adapter);

        buildingList.setOnChildClickListener(new ExpandableListView.OnChildClickListener() {
            @Override
            public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
                Building building = buildings.get(groupPosition);
                Room room = building.Rooms.get(childPosition);
                StaticData.CheckInRoomID = room.RoomID;
                new InCanceledAlterDialog.Builder( RoomListActivity.this).setMessage("是否已经到达房间？\n\n" + building.BuildingName + " " + room.RoomName)
                        .setPositiveButton("立刻签到", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                startActivity(new Intent().setClass(RoomListActivity.this, FaceDetectSimpleActivity.class));
                            }
                        }).setNegativeButton("稍等一下", null).show();
                return false;
            }
        });

        setSupportActionBar((Toolbar)findViewById(R.id.RL_toolbar));
    }
}

class BuildingRoomAdapter extends BaseExpandableListAdapter {
    private Context host;
    private List<Building> buildings;

    public BuildingRoomAdapter(Context context, List<Building> buildings) {
        host = context;
        this.buildings = buildings;
    }

    //父项的个数
    @Override
    public int getGroupCount() {
        return buildings.size();
    }
    //某个父项的子项的个数
    @Override
    public int getChildrenCount(int groupPosition) {
        return buildings.get(groupPosition).Rooms.size();
    }
    //获得某个父项
    @Override
    public Building getGroup(int groupPosition) {
        return buildings.get(groupPosition);
    }
    //获得某个子项
    @Override
    public Room getChild(int groupPosition, int childPosition) {
        return buildings.get(groupPosition).Rooms.get(childPosition);
    }
    //父项的Id
    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }
    //子项的id
    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }
    @Override
    public boolean hasStableIds() {
        return false;
    }
    //获取父项的view
    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {
        if (convertView == null){
            convertView = LayoutInflater.from(host).inflate(R.layout.table_roomlist_building_item,parent,false);
        }
        ((TextView) convertView.findViewById(R.id.RL_ITEM_buildingname)).setText(getGroup(groupPosition).BuildingName);
        return convertView;
    }
    //获取子项的view
    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild, View convertView, ViewGroup parent) {
        if (convertView == null){
            convertView = LayoutInflater.from(host).inflate(R.layout.table_roomlist_room_item,parent,false);
        }
        ((TextView) convertView.findViewById(R.id.RL_ITEM_roomname)).setText(getChild(groupPosition, childPosition).RoomName);
        return convertView;
    }
    //子项是否可选中,如果要设置子项的点击事件,需要返回true
    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }
}
