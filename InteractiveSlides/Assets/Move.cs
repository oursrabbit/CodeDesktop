using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour
{
    public GameObject Obj;
    private float axisX;
    private float axisY;

    private Vector3 prePos;
    private Vector3 nowPos;

    private void Start()
    {
        prePos = Vector3.zero;
    }

    void FixedUpdate()
    {
        nowPos = Input.mousePosition;
        //print("Move 0" + Input.GetMouseButton(0));
        //print("Move 1" + Input.GetMouseButton(1));
        if (Input.GetMouseButton(0))
        {
            print("MOVE");
            //Destroy(Globle.ShowVideo);
            if (Mathf.Abs(nowPos.x - prePos.x) > 0)
            {
                axisX = -(nowPos.x - prePos.x) * Time.deltaTime * 30;
            }
            else
            {
                axisX = 0;
            }
            if (Mathf.Abs(nowPos.y - prePos.y) > 0)
            {
                axisY = -(nowPos.y - prePos.y) * Time.deltaTime * 30;
            }
            else
            {
                axisY = 0;
            }
            this.transform.Rotate(new Vector3(-axisY, axisX, 0), Space.World);
            //if (Globle.ShowVideo != null)
                //Globle.ShowVideo.GetComponent<Transform>().Rotate(new Vector3(0, axisX, 0), Space.World);
        }
        else
        {
            axisX = 0;

        }

        // 记录上次鼠标位置
        prePos = Input.mousePosition;
    }
}

