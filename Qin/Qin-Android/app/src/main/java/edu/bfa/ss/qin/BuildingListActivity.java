package edu.bfa.ss.qin;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.GridView;
import android.widget.TextView;

import java.util.List;

import edu.bfa.ss.qin.Custom.UI.InCanceledAlterDialog;
import edu.bfa.ss.qin.Custom.UI.StaticAppCompatActivity;
import edu.bfa.ss.qin.Util.ApplicationHelper;
import edu.bfa.ss.qin.Util.Building;
import edu.bfa.ss.qin.Util.Room;
import io.realm.Realm;
import io.realm.RealmResults;

public class BuildingListActivity extends StaticAppCompatActivity {

    private RealmResults<Building> buildings;

    private TextView studentNameLabel;

    /*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_room_list_actionbar,menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        switch (item.getItemId()) {
            case R.id.RL_MENU_schedule:
                startActivity(new Intent().setClass(BuildingListActivity.this, QinSettingActivity.class));
                return true;
            case R.id.RL_MENU_changeuser:
                startActivity(new Intent().setClass(BuildingListActivity.this, CheckDBActivity.class));
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }*/

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_building_list);

        studentNameLabel = findViewById(R.id.BL_studentname);

        studentNameLabel.setText("你好，" + ApplicationHelper.CurrentUser.Name);

        Realm.init(this);
        Realm realm = Realm.getDefaultInstance();

        buildings = realm.where(Building.class).findAll().sort("ID");

        bindingAdaper();
/*
        buildingList = findViewById(R.id.BL_roomlist);
        BuildingRoomAdapter adapter = new BuildingRoomAdapter(this, buildings);
        buildingList.setAdapter(adapter);

        buildingList.setOnChildClickListener(new ExpandableListView.OnChildClickListener() {
            @Override
            public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
                Building building = buildings.get(groupPosition);
                Room room = building.Rooms.get(childPosition);
                //ApplicationHelper.CheckInRoomID = room.BLE;
                new InCanceledAlterDialog.Builder( BuildingListActivity.this).setMessage("是否已经到达房间？\n\n" + building.Name + " " + room.Name)
                        .setPositiveButton("立刻签到", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                startActivity(new Intent().setClass(BuildingListActivity.this, FaceDetectSimpleActivity.class));
                            }
                        }).setNegativeButton("稍等一下", null).show();
                return false;
            }
        });*/

        //setSupportActionBar((Toolbar)findViewById(R.id.RL_toolbar));
    }

    private void bindingAdaper(){
        GridView gridView = findViewById(R.id.BL_buildingcollection);
        gridView.setAdapter(new BuildingCollectionAdapter(this, R.layout.grid_buildinglist, buildings));
        int cellWidth = gridView.getWidth() - 32 /2;
        if (cellWidth < 147) {
            gridView.setNumColumns(2);
        }
    }
}

class BuildingCollectionAdapter extends ArrayAdapter<Building> {
    private Context host;
    private int resourceId;

    public BuildingCollectionAdapter(Context context, int resource, List<Building> objects) {
        super(context, resource, objects);
        resourceId = resource;
        host = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup container) {
        if (convertView == null) {
            convertView = LayoutInflater.from(host).inflate(resourceId, container, false);
        }
        Building building = getItem(position);
        ((TextView) convertView.findViewById(R.id.BL_ITEM_buildingname)).setText(building.Name);
        ((TextView) convertView.findViewById(R.id.BL_ITEM_roomcount)).setText(building.Rooms.size() + " 间教室");
        return convertView;
    }
}
