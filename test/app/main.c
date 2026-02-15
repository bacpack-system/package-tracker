
extern int shared_out_of_dir_symlink();
extern int shared_with_soname();

#ifdef USE_GST_LIBRARY
extern int shared_gst_func();
#endif

int main() {

    int r = shared_out_of_dir_symlink() + shared_with_soname();
    
#ifdef USE_GST_LIBRARY
    r += shared_gst_func();
#endif

    return r;

}