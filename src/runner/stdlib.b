def array_map(a, f) {
    b := [];
    i := 0;
    while(i < len(a)) {
        b[len(b)] := f(a[i]);
        i := i + 1;
    }
    return b;
}

def array_join(a, delim) {
    s := "";
    i := 0;
    while(i < len(a)) {
        if(i > 0) {
            s := s + delim;
        }
        s := s + a[i];
        i := i + 1;
    }
    return s;
}

def array_filter(a, f) {
    b := [];
    i := 0;
    while(i < len(a)) {
        if(f(a[i])) {
            b[len(b)] := a[i];
        }
        i := i + 1;
    }
    return b;
}

def array_find_index(array, fx) {
    i := 0; 
    while(i < len(array)) {
        if(fx(array[i])) {
            return i;
        }
        i := i + 1;
    }
    return -1;
}

def array_find(array, fx) {
    i := 0; 
    while(i < len(array)) {
        if(fx(array[i])) {
            return array[i];
        }
        i := i + 1;
    }
    return null;
}

def array_foreach(array, fx) {
    i := 0; 
    while(i < len(array)) {
        fx(i, array[i]);
        i := i + 1;
    }
}

def choose(array) {
    if(len(array) > 0) {
        return array[random() * len(array)];
    } else {
        return null;
    }
}

def roll(minValue, maxValue) {
    return int(random() * (maxValue - minValue)) + minValue;
}

# todo: make this more efficient
def sort(array, fx) {
    i := 0;
    while(i < len(array)) {
        t := 0;
        while(t < len(array)) {
            if(fx(array[i], array[t]) < 0) {
                tmp := array[i];
                array[i] := array[t];
                array[t] := tmp;
            }
            t := t + 1;
        }
        i := i + 1;
    }
}

def basic_sort(array) {
    sort(array, (a,b) => {
        if(a < b) {
            return -1;
        } else {
            return 1;
        }
    });
}

def basic_sort_copy(array) {
    a := copy_array(array);
    basic_sort(a);
    return a;
}

def array_reverse(array) {
    ret := [];
    i := len(array) - 1;
    while(i >= 0) {
        ret[len(ret)] := array[i];
        i := i - 1;
    }
    return ret;    
}

def array_reduce(array, value, fx) {
    i := 0; 
    while(i < len(array)) {
        value := fx(value, array[i]);
        i := i + 1;
    }
    return value;
}

def array_remove(array, fx) {
    i := 0; 
    while(i < len(array)) {
        if(fx(array[i])) {
            del array[i];
        } else {
            i := i + 1;
        }
    }
}

def pow(n, e) {
    if(e = 0) {
        return 1;
    }
    if(e = 1) {
        return n;
    }
    return n * pow(n, e - 1);
}

# shallow-copy a map object
def copy_map(m) {
    return array_reduce(keys(m), {}, (d, k) => { d[k] := m[k]; return d; });
}

# shallow-copy a map object
def copy_array(m) {
    return array_reduce(m, [], (d, e) => { d[len(d)] := e; return d; });
}

def range(start, end, step, fx) {
    i := start;
    while(i < end) {
        fx(i);
        i := i + step;
    }
}

def asPercent(n) {
    return round(n * 100);
}

def startsWith(str, prefix) {
    return substr(str, 0, len(prefix)) = prefix;
}

def endsWith(str, suffix) {
    return substr(str, len(str) - len(suffix), len(suffix)) = suffix;
}

def normalize(x) {
    if(x = 0) {
        return 0;
    }
    return x/abs(x);
}
