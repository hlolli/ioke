/*
 * See LICENSE file in distribution for copyright and licensing information.
 */
package ioke.lang.test;

/**
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class SimpleInterfaceUser {
    public static String useObject(SimpleInterface si) {
        return si.doSomething();
    }
}// SimpleInterfaceUser
