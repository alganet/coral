Given the `myfile.sh` file:

~~~sh file myfile.sh
echo 123
~~~

Yon can run:

~~~terminal
$ false
$ echo $?
0
$ chmod +x myfile.sh
$ ./myfile.sh
123
$ echo $?
0
~~~


