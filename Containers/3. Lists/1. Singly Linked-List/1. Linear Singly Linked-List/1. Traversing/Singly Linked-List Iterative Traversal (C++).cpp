#include<iostream>
#include<stdlib.h>

using namespace std;

class list
{
    class node
    {
        public:
        int value;
        node *next;
        node(int _value)
        {
            next=NULL;
            value=_value;
        }
    }*first,*last;
    void destroy(node *ptr)
    {
        if(!ptr) return;
        destroy(ptr->next);
        delete ptr;
    }
    public:
    list()
    {
        first=NULL;
        last=NULL;
    }
    int empty()
    {
        if(!first)
        return 1;
        return 0;
    }
    void append(int value)
    {
        node *x=new node(value);
        if(first) last->next=x;
        else first=x; last=x;
    }
    void forward()
    {
        node *ptr=first;
        while(ptr)
        {
            cout<<ptr->value<<", ";
            ptr=ptr->next;
        }
    }
    void backward()
    {
        node *temp,*ptr;
        node *mark=last;
        while(mark!=first)
        {
            temp=first;
            ptr=temp->next;
            while(ptr!=mark)
            {
                temp=temp->next;
                ptr=temp->next;
            }
            mark=temp;
            cout<<ptr->value<<", ";
        }
        cout<<first->value;
    }
    void destroy()
    {
        if(!first) return;
        destroy(first);
        first=NULL;
        last=NULL;
    }
};

int main()
{
    list lst;
    int ch,value;
    do
    {
        system("cls");
        cout<<"\n 1. Append ";
        cout<<"\n 2. Forward ";
        cout<<"\n 3. Backward ";
        cout<<"\n 4. End Program ";
        cout<<"\n\n Enter>>";
        cin>>ch; switch(ch)
        {
            case 1 :
            cout<<"\n Enter a value : ";
            cin>>value; lst.append(value);
            break;

            case 2 :
            cout<<"\n List is : ";
            if(!lst.empty())
            lst.forward();
            else cout<<"empty!";
            cout<<"\n "; system("pause");
            break;

            case 3 :
            cout<<"\n List is : ";
            if(!lst.empty())
            lst.backward();
            else cout<<"empty!";
            cout<<"\n "; system("pause");
            break;

            case 0 :
            lst.destroy();
            break;
        }
    }while(ch!=4);
}
