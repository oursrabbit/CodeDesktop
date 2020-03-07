using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnMyClicked : MonoBehaviour
{
    public GameObject videoObjectOY;
    public Transform parent;
    public Transform showTransform;
    // Start is called before the first frame update

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit rayhit;
        if (Physics.Raycast(ray, out rayhit))
        {
            //Debug.Log(rayhit.collider.gameObject.name);
            //Debug.DrawLine(ray.origin, rayhit.point, Color.green);
            if (Input.GetMouseButtonUp(1) && rayhit.collider.tag.Equals("Finish"))
            {
                Globle.ShowVideo = Instantiate(videoObjectOY, showTransform, parent) as GameObject;
            }
        }    
    }
}
