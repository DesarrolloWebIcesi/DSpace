/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.checker;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.ParseException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Utils;

/**
 * Manages the deletion of results from the checksum history. It uses the
 * dspace.cfg file as the default configuration file for the deletion settings
 * and can use a different configuration file if it is passed in.
 * 
 * @author Jim Downing
 * @author Grace Carpenter
 * @author Nathan Sarr
 * 
 * 
 */
public final class ResultsPruner
{

    /**
     * Default logger.
     */
    private static final Logger LOG = Logger.getLogger(ResultsPruner.class);

    /**
     * Factory method for the default results pruner configuration using
     * dspace.cfg
     * 
     * @return a ResultsPruner that represent the default retention policy
     */
    public static ResultsPruner getDefaultPruner()
    {
        try
        {
            return getPruner(ConfigurationManager.getProperties());
        }
        catch (FileNotFoundException e)
        {
            throw new IllegalStateException(
                    "VeryExceptionalException - config file not there! ", e);
        }

    }

    
    /**
     * Factory method for ResultsPruners
     * 
     * @param propsFile
     *            to configure the results pruner.
     * @return the configured results pruner.
     * @throws FileNotFoundException
     *             it the configuration file cannot be found.
     */
    public static ResultsPruner getPruner(String propsFile)
            throws FileNotFoundException
    {
        Properties props = new Properties();
        FileInputStream fin = null;
        try
        {
            fin = new FileInputStream(propsFile);
            props.load(fin);
            
            return getPruner(props);
        }
        catch (IOException e)
        {
            throw new IllegalStateException("Problem loading properties file: "
                    + e.getMessage(), e);
        }
        finally
        {
            if (fin != null)
            {
                try
                {
                    fin.close();
                }
                catch (IOException e)
                {
                    LOG.warn(e);
                }
            }
        }
    }
    
    /**
     * Factory method for ResultsPruners (used to load ConfigurationManager
     * properties.
     * 
     * @param props
     * @throws FileNotFoundException
     */
    public static ResultsPruner getPruner(Properties props)
    throws FileNotFoundException
    {
     
        ResultsPruner rp = new ResultsPruner();
        Pattern retentionPattern = Pattern
                .compile("checker\\.retention\\.(.*)");
        for (Enumeration<String> en = (Enumeration<String>)props.propertyNames(); en.hasMoreElements();)
        {
            String name = en.nextElement();
            Matcher matcher = retentionPattern.matcher(name);
            if (!matcher.matches())
            {
                continue;
            }
            String resultCode = matcher.group(1);
            long duration;
            try
            {
                duration = Utils.parseDuration(props.getProperty(name));
            }
            catch (ParseException e)
            {
                throw new IllegalStateException("Problem parsing duration: "
                        + e.getMessage(), e);
            }
            if ("default".equals(resultCode))
            {
                rp.setDefaultDuration(duration);
            }
            else
            {
                rp.addInterested(resultCode, duration);
            }
        }
        return rp;
        
    }

    /** Ten years */
    private long defaultDuration = 31536000000L;

    /**
     * Map of retention durations, keyed by result code name
     */
    Map<String, Long> interests = new HashMap<String, Long>();

    /**
     * Checksum results database Data access
     */
    private ChecksumResultDAO checksumResultDAO = null;

    /**
     * Checksum history database data access.
     */
    private ChecksumHistoryDAO checksumHistoryDAO = null;

    /**
     * Default Constructor
     */
    public ResultsPruner()
    {
        checksumResultDAO = new ChecksumResultDAO();
        checksumHistoryDAO = new ChecksumHistoryDAO();
    }

    /**
     * Add a result and the length of time before the history with this type of
     * result is removed from the database.
     * 
     * @param result
     *            code in the database.
     * 
     * @param duration
     *            before bitstreams with the specified result type in the
     *            checksum history is removed.
     */
    public void addInterested(String result, long duration)
    {
        interests.put(result, Long.valueOf(duration));
    }

    /**
     * Add a result and the length of time before it is removed from the
     * checksum history table.
     * 
     * @param result
     *            code in the database.
     * 
     * @param duration
     *            before bitstreams with the specified result type in the
     *            checksum history is removed.
     * 
     * @throws ParseException
     *             if the duration cannot be parsed into a long value.
     */
    public void addInterested(String result, String duration)
            throws ParseException
    {
        addInterested(result, Utils.parseDuration(duration));
    }

    /**
     * The default amount of time before a result is removed.
     * 
     * @return the default duration.
     */
    public long getDefaultDuration()
    {
        return defaultDuration;
    }

    /**
     * Prunes the results retaining results as configured by the interests
     * registered with this object.
     * 
     * @return number of results removed.
     */
    public int prune()
    {
        List<String> codes = checksumResultDAO.listAllCodes();
        for (String code : codes)
        {
            if (!interests.containsKey(code))
            {
                interests.put(code, Long.valueOf(defaultDuration));
            }

        }
        return checksumHistoryDAO.prune(interests);
    }

    /**
     * The default duration before records are removed from the checksum history
     * table.
     * 
     * @param defaultDuration
     *            used before records are removed from the checksum history.
     */
    public void setDefaultDuration(long defaultDuration)
    {
        this.defaultDuration = defaultDuration;
    }
}
