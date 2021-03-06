/*
 * Copyright (c) 2019-2020 Alecaddd (https://alecaddd.com)
 *
 * This file is part of Akira.
 *
 * Akira is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * Akira is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with Akira. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Felipe Escoto <felescoto95@hotmail.com>
 * Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
 */

public class Akira.FileFormat.JsonObject : GLib.Object {
    public Lib.Models.CanvasItem? item { get; construct; }

    private Json.Object object;
    private Json.Object transform;
    private ObjectClass obj_class;

    public JsonObject (Lib.Models.CanvasItem? item) {
        Object (item: item);
    }

    construct {
        object = new Json.Object ();
        obj_class = (ObjectClass) item.get_type ().class_ref ();

        object.set_string_member ("type", item.get_type ().name ());

        foreach (ParamSpec spec in obj_class.list_properties ()) {
            if (!(ParamFlags.READABLE in spec.flags)) {
                continue;
            }
            write_key (spec, object);
        }

        transform = new Json.Object ();
        write_transform ();
    }

    public Json.Node get_node () {
        var node = new Json.Node.alloc ();
        node.set_object (object);

        return node;
    }

    private void write_key (ParamSpec spec, Json.Object obj) {
        var type = spec.value_type;
        var val = Value (type);

        if (type == typeof (int)) {
            item.get_property (spec.get_name (), ref val);
            obj.set_int_member (spec.get_name (), val.get_int ());
            //  debug ("%s: %i", spec.get_name (), val.get_int ());
        } else if (type == typeof (uint)) {
            item.get_property (spec.get_name (), ref val);
            obj.set_int_member (spec.get_name (), val.get_uint ());
            //  debug ("%s: %s", spec.get_name (), val.get_uint ().to_string ());
        } else if (type == typeof (double)) {
            item.get_property (spec.get_name (), ref val);
            obj.set_double_member (spec.get_name (), val.get_double ());
            //  debug ("%s: %f", spec.get_name (), val.get_double ());
        } else if (type == typeof (string)) {
            item.get_property (spec.get_name (), ref val);
            obj.set_string_member (spec.get_name (), val.get_string ());
            //  debug ("%s: %s", spec.get_name (), val.get_string ());
        } else if (type == typeof (bool)) {
            item.get_property (spec.get_name (), ref val);
            obj.set_boolean_member (spec.get_name (), val.get_boolean ());
            //  debug ("%s: %s", spec.get_name (), val.get_boolean ().to_string ());
        } else if (type == typeof (int64)) {
            item.get_property (spec.get_name (), ref val);
            obj.set_int_member (spec.get_name (), val.get_int64 ());
            //  debug ("%s: %s", spec.get_name (), val.get_int64 ().to_string ());
        } else if (type == typeof (Akira.Lib.Models.CanvasArtboard)) {
            item.get_property (spec.get_name (), ref val);
            if (val.strdup_contents () != "NULL") {
                obj.set_string_member (spec.get_name (), (val as Akira.Lib.Models.CanvasArtboard).id);
            }
        } else if (type == typeof (Goo.CanvasItemVisibility)) {
            item.get_property (spec.get_name (), ref val);
            obj.set_int_member (spec.get_name (), val.get_enum ());
        } else {
            //  warning ("Property type %s not yet supported: %s\n", type.name (), spec.get_name ());
        }
    }

    private void write_transform () {
        var matrix = Cairo.Matrix.identity ();
        item.get_transform (out matrix);

        transform.set_double_member ("xx", matrix.xx);
        transform.set_double_member ("yx", matrix.yx);
        transform.set_double_member ("xy", matrix.xy);
        transform.set_double_member ("yy", matrix.yy);
        transform.set_double_member ("x0", matrix.x0);
        transform.set_double_member ("y0", matrix.y0);

        object.set_object_member ("transform", transform);
    }
}
