import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
class AppP02C extends StatefulWidget {
   AppP02C({super.key});

  @override
  State<AppP02C> createState() => _AppP02CState();
}

class _AppP02CState extends State<AppP02C> {
  int nprofesor = 0;
  var nombre = TextEditingController();
  var carrera = TextEditingController();
  int nhorario = 0;
  int idasistencia = 0;
  String fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());
  bool asistencia = false;
  int nmat = 0;
  var descripcion = TextEditingController();
  TimeOfDay? hora;
  List <String> edificio = ['A', 'C', 'G', 'H', 'L', 'M' , 'Q', 'Z'];
  List <int> salon = [1,2,3,4,5,6,7,8];
  String? itemSeleccionadoE;
  int? itemSeleccionadoS;
  List <String> datos1 = [];
  List <String> datos2 = [];
  List <String> datos3 = [];
  int _currentIndex = 0;
  late DateTime _diaSeleccionado = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AppP02: Checador de profesores"),
        centerTitle: true,
        backgroundColor: Colors.orange,

      ),
      body: contenido(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Formulario/Detalle profesor"),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Formulario/Detalle asistencia"),
          BottomNavigationBarItem(icon: Icon(Icons.subject), label: "Formulario/Detalle materia"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Formulario/Detalle horario"),
        ],
        currentIndex: _currentIndex,
        onTap: (pos){
          setState(() {
            _currentIndex=pos;
          });
        },
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.orange,
      ),
    );
  }
  Widget formularioDetalleProfesor(){
    return Padding(
      padding: EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          child: Column(
            children: [
              Text(
                "NP: $nprofesor"
              ),
              SizedBox(height: 8),
              TextField(
                controller: nombre,
                decoration: InputDecoration(
                    labelText: "Nombre:"
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: carrera,
                decoration: InputDecoration(
                    labelText: "Carrera:"
                ),
              ),
             SizedBox(height: 16),
             OutlinedButton(onPressed: (){}, child: Text("Insertar")),

             /* Row(
                children: [
                  FilledButton(
                      onPressed: (){
                        Automovil a= Automovil(
                            placa: placa.text,
                            marca: marca.text,
                            modelo: modelo.text,
                            anio: int.parse(anio.text),
                            costo: double.parse(costo.text)
                        );
                        DB.insertar(a).then((respuesta){ //Then espera por una promesa para que se realice.
                          if(respuesta<=0){
                            setState(() {
                              titulo="No se insertó debidamente";
                            });
                          }else{
                            setState(() {
                              titulo="Se insertó el automóvil correctamente: $respuesta";
                            });
                          }
                          actualizarLista();
                        });
                      },
                      child: Text("Insertar")
                  ),
                  FilledButton(
                      onPressed: (){
                        placa.text="";
                        marca.text="";
                        modelo.text="";
                        anio.text="";
                        costo.text="";
                      },
                      child: Text("Limpiar")
                  ),
                  FilledButton(
                      onPressed: (){
                        Automovil a= Automovil(
                            placa: placa.text,
                            marca: marca.text,
                            modelo: modelo.text,
                            anio: int.parse(anio.text),
                            costo: double.parse(costo.text)
                        );
                        DB.actualizar(a).then((respuesta){ //Then espera por una promisa para que se realice.
                          if(respuesta<=0){
                            setState(() {
                              titulo="No se actualizó debidamente";
                            });
                          }else{
                            setState(() {
                              titulo="Se actualizó correctamente: $respuesta";
                            });
                          }
                          actualizarLista();
                        });
                      },
                      child: Text("Actualizar")
                  ),
                ],
              )
            ],
          ),
        ),*/
        /*Expanded(
            child: ListView.builder(
                itemCount: datos1.length,
                itemBuilder: (context,contador){
                  return ListTile(
                    title: Text(datos1[contador].nombre),
                    subtitle: Text(datos1[contador].carrera),
                    leading: CircleAvatar(
                      child: Text(contador.toString()),
                    ),
                    trailing: IconButton(
                        onPressed: (){
                          //ALERT DIALOG PARA ELIMINAR
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirmación de eliminación"),
                                content: Text("¿Estás seguro que quieres eliminar este registro?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        DB.eliminar(datos1[contador].placa).then((respuesta){
                                          actualizarLista();
                                        });
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Registro eliminado"))
                                      );
                                    },
                                    child: Text("Sí"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("No"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete)
                    ),
                    onTap: (){
                      placa.text=datos[contador].placa;
                      marca.text=datos[contador].marca;
                      modelo.text=datos[contador].modelo;
                      anio.text=datos[contador].anio.toString();
                      costo.text=datos[contador].costo.toString();
                    },
                  );
                }
            )
        ),*/
        ],
       ),
       ),
      ]
      )
      )
    );
  }
  Widget formularioDetalleAsistencia(){
    return Padding(
      padding: EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                    Text(
                        'ID: $idasistencia'
                    ),
                    SizedBox(height: 8),
                    Text(
                        'NHorario: $nhorario'
                    ),
                    SizedBox(height: 8),
                    Text(
                        'Fecha: ${fecha}'
                    ),
                    SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _mostrarDialogoDeFecha(context),
                      child: Text("Seleccionar fecha"),
                    ),
                    SizedBox(height: 8),
                    Text('Asistencia: $asistencia'),
                    SizedBox(height: 16),
                    OutlinedButton(onPressed: (){}, child: Text("Insertar")),
                    /* Row(
                  children: [
                    FilledButton(
                        onPressed: (){
                          Automovil a= Automovil(
                              placa: placa.text,
                              marca: marca.text,
                              modelo: modelo.text,
                              anio: int.parse(anio.text),
                              costo: double.parse(costo.text)
                          );
                          DB.insertar(a).then((respuesta){ //Then espera por una promesa para que se realice.
                            if(respuesta<=0){
                              setState(() {
                                titulo="No se insertó debidamente";
                              });
                            }else{
                              setState(() {
                                titulo="Se insertó el automóvil correctamente: $respuesta";
                              });
                            }
                            actualizarLista();
                          });
                        },
                        child: Text("Insertar")
                    ),
                    FilledButton(
                        onPressed: (){
                          placa.text="";
                          marca.text="";
                          modelo.text="";
                          anio.text="";
                          costo.text="";
                        },
                        child: Text("Limpiar")
                    ),
                    FilledButton(
                        onPressed: (){
                          Automovil a= Automovil(
                              placa: placa.text,
                              marca: marca.text,
                              modelo: modelo.text,
                              anio: int.parse(anio.text),
                              costo: double.parse(costo.text)
                          );
                          DB.actualizar(a).then((respuesta){ //Then espera por una promisa para que se realice.
                            if(respuesta<=0){
                              setState(() {
                                titulo="No se actualizó debidamente";
                              });
                            }else{
                              setState(() {
                                titulo="Se actualizó correctamente: $respuesta";
                              });
                            }
                            actualizarLista();
                          });
                        },
                        child: Text("Actualizar")
                    ),
                  ],
                )
              ],
            ),
          ),*/
                    /*Expanded(
              child: ListView.builder(
                  itemCount: datos1.length,
                  itemBuilder: (context,contador){
                    return ListTile(
                      title: Text(datos1[contador].nombre),
                      subtitle: Text(datos1[contador].carrera),
                      leading: CircleAvatar(
                        child: Text(contador.toString()),
                      ),
                      trailing: IconButton(
                          onPressed: (){
                            //ALERT DIALOG PARA ELIMINAR
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmación de eliminación"),
                                  content: Text("¿Estás seguro que quieres eliminar este registro?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          DB.eliminar(datos1[contador].placa).then((respuesta){
                                            actualizarLista();
                                          });
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Registro eliminado"))
                                        );
                                      },
                                      child: Text("Sí"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("No"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.delete)
                      ),
                      onTap: (){
                        placa.text=datos[contador].placa;
                        marca.text=datos[contador].marca;
                        modelo.text=datos[contador].modelo;
                        anio.text=datos[contador].anio.toString();
                        costo.text=datos[contador].costo.toString();
                      },
                    );
                  }
              )
          ),*/
        ]
      ),
    ),
    );
  }
  Widget formularioDetalleMateria(){
    return Padding(
      padding: EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          children: [
                  Text(
                    'NMat: $nmat'
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: descripcion,
                    decoration: InputDecoration(
                        labelText: "Descripción:"
                    ),
                    maxLines: null,
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(onPressed: (){}, child: Text("Insertar")),
                 /*
                  Row(
                    children: [
                      FilledButton(
                          onPressed: (){
                            Automovil a= Automovil(
                                placa: placa.text,
                                marca: marca.text,
                                modelo: modelo.text,
                                anio: int.parse(anio.text),
                                costo: double.parse(costo.text)
                            );
                            DB.insertar(a).then((respuesta){ //Then espera por una promesa para que se realice.
                              if(respuesta<=0){
                                setState(() {
                                  titulo="No se insertó debidamente";
                                });
                              }else{
                                setState(() {
                                  titulo="Se insertó el automóvil correctamente: $respuesta";
                                });
                              }
                              actualizarLista();
                            });
                          },
                          child: Text("Insertar")
                      ),
                      FilledButton(
                          onPressed: (){
                            placa.text="";
                            marca.text="";
                            modelo.text="";
                            anio.text="";
                            costo.text="";
                          },
                          child: Text("Limpiar")
                      ),
                      FilledButton(
                          onPressed: (){
                            Automovil a= Automovil(
                                placa: placa.text,
                                marca: marca.text,
                                modelo: modelo.text,
                                anio: int.parse(anio.text),
                                costo: double.parse(costo.text)
                            );
                            DB.actualizar(a).then((respuesta){ //Then espera por una promisa para que se realice.
                              if(respuesta<=0){
                                setState(() {
                                  titulo="No se actualizó debidamente";
                                });
                              }else{
                                setState(() {
                                  titulo="Se actualizó correctamente: $respuesta";
                                });
                              }
                              actualizarLista();
                            });
                          },
                          child: Text("Actualizar")
                      ),
                    ],
                  )
                ],
              ),
            ),*/
          /*  Expanded(
                child: ListView.builder(
                    itemCount: datos.length,
                    itemBuilder: (context,contador){
                      return ListTile(
                        title: Text(datos[contador].modelo),
                        subtitle: Text(datos[contador].placa),
                        leading: CircleAvatar(
                          child: Text(contador.toString()),
                        ),
                        trailing: IconButton(
                            onPressed: (){
                              //ALERT DIALOG PARA ELIMINAR
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Confirmación de eliminación"),
                                    content: Text("¿Estás seguro que quieres eliminar este registro?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            DB.eliminar(datos[contador].placa).then((respuesta){
                                              actualizarLista();
                                            });
                                          });

                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Registro eliminado"))
                                          );
                                        },
                                        child: Text("Sí"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("No"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.delete)
                        ),
                        onTap: (){
                          placa.text=datos[contador].placa;
                          marca.text=datos[contador].marca;
                          modelo.text=datos[contador].modelo;
                          anio.text=datos[contador].anio.toString();
                          costo.text=datos[contador].costo.toString();
                        },
                      );
                    }
                );
            ),*/
          ],
        ),
      ),
    );
  }
  Widget formularioDetalleHorario(){
    return Padding(
      padding: EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
                children: [
                  Text(
                    'NHorario: $nhorario'
                  ),
                  SizedBox(height: 8),
                  Text(
                    'NProfesor: $nprofesor'
                  ),
                  SizedBox(height: 8),
                  Text(
                    'NMat: $nmat'
                  ),
                  SizedBox(height: 8),
                  Text(
                    hora != null
                        ? 'Hora seleccionada: ${hora!.format(context)}'
                        : 'Hora: (No seleccionada)',
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Aquí llamaremos a la función que muestra el selector
                      _mostrarSelectorDeHora(context);
                    },
                    child:  Text('Seleccionar Hora'),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: itemSeleccionadoE,
                    hint: Text("Seleccione un edificio:"),
                    items: edificio.map((n) {
                      return DropdownMenuItem(value: n, child: Text(n));
                    }).toList(),
                    onChanged: (String? x) {
                      if (x != null) setState(() => itemSeleccionadoE = x);
                    },
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: itemSeleccionadoS,
                    hint: Text("Seleccione un salón:"),
                    items: salon.map((n) {
                      return DropdownMenuItem(value: n, child: Text('${n}'));
                    }).toList(),
                    onChanged: (int? x) {
                      if (x != null) setState(() => itemSeleccionadoS = x);
                    },
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(onPressed: (){}, child: Text("Insertar")),
                /*  Row(
                    children: [
                      FilledButton(
                          onPressed: (){
                            Automovil a= Automovil(
                                placa: placa.text,
                                marca: marca.text,
                                modelo: modelo.text,
                                anio: int.parse(anio.text),
                                costo: double.parse(costo.text)
                            );
                            DB.insertar(a).then((respuesta){ //Then espera por una promesa para que se realice.
                              if(respuesta<=0){
                                setState(() {
                                  titulo="No se insertó debidamente";
                                });
                              }else{
                                setState(() {
                                  titulo="Se insertó el automóvil correctamente: $respuesta";
                                });
                              }
                              actualizarLista();
                            });
                          },
                          child: Text("Insertar")
                      ),
                      FilledButton(
                          onPressed: (){
                            placa.text="";
                            marca.text="";
                            modelo.text="";
                            anio.text="";
                            costo.text="";
                          },
                          child: Text("Limpiar")
                      ),
                      FilledButton(
                          onPressed: (){
                            Automovil a= Automovil(
                                placa: placa.text,
                                marca: marca.text,
                                modelo: modelo.text,
                                anio: int.parse(anio.text),
                                costo: double.parse(costo.text)
                            );
                            DB.actualizar(a).then((respuesta){ //Then espera por una promisa para que se realice.
                              if(respuesta<=0){
                                setState(() {
                                  titulo="No se actualizó debidamente";
                                });
                              }else{
                                setState(() {
                                  titulo="Se actualizó correctamente: $respuesta";
                                });
                              }
                              actualizarLista();
                            });
                          },
                          child: Text("Actualizar")
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: datos.length,
                    itemBuilder: (context,contador){
                      return ListTile(
                        title: Text(datos[contador].modelo),
                        subtitle: Text(datos[contador].placa),
                        leading: CircleAvatar(
                          child: Text(contador.toString()),
                        ),
                        trailing: IconButton(
                            onPressed: (){
                              //ALERT DIALOG PARA ELIMINAR
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Confirmación de eliminación"),
                                    content: Text("¿Estás seguro que quieres eliminar este registro?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            DB.eliminar(datos[contador].placa).then((respuesta){
                                              actualizarLista();
                                            });
                                          });

                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Registro eliminado"))
                                          );
                                        },
                                        child: Text("Sí"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("No"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.delete)
                        ),
                        onTap: (){
                          placa.text=datos[contador].placa;
                          marca.text=datos[contador].marca;
                          modelo.text=datos[contador].modelo;
                          anio.text=datos[contador].anio.toString();
                          costo.text=datos[contador].costo.toString();
                        },
                      );
                    }
                )
            ),*/
          ]
        ),
      ),
    );
  }
  Future<void> _mostrarSelectorDeHora(BuildContext context) async {

    final TimeOfDay? horaObtenida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );


    if (horaObtenida != null) {

      setState(() {
        hora = horaObtenida;
      });
    }
  }
  void _mostrarDialogoDeFecha(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text("Selecciona una Fecha"),
              contentPadding: EdgeInsets.all(0),
              content: SizedBox(
                height: 400,
                width: 350,
                child: TableCalendar(
                  locale: 'es_ES',
                  focusedDay: _diaSeleccionado,
                  firstDay: DateTime.now(),
                  lastDay: DateTime.utc(2025, 12, 31),
                  headerStyle: HeaderStyle(
                      titleCentered: true, formatButtonVisible: false),

                  selectedDayPredicate: (dia) {
                    return isSameDay(_diaSeleccionado, dia);
                  },

                  onDaySelected: (diaSeleccionado, diaMarcado) {
                    _diaSeleccionado = diaMarcado;
                    fecha = DateFormat('dd/MM/yyyy').format(_diaSeleccionado);

                    setStateDialog(() {

                    });
                    setState(() {});
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Widget contenido() {
    switch(_currentIndex){
      case 1: return formularioDetalleAsistencia();
      case 2: return formularioDetalleMateria();
      case 3: return formularioDetalleHorario();
      default: return formularioDetalleProfesor();
    }

  }

}



