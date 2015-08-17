abstract class A{
    Object uniqueObject();
    Object uniqueObject(Object obj);
    T uniqueResult(T : Object)(T obj) {
        return cast(T)uniqueObject(obj);
    }
}
class B : A{
    override Object uniqueObject() {
        return uniqueResult(null);
    }
    override Object uniqueObject(Object obj){
        return null;
    }
}
